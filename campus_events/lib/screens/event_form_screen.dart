import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_category.dart';
import '../utils/format.dart';

/// One screen for both "new" (event == null) and "edit". Returns the saved
/// event through Navigator.pop; backing out returns null.
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  final Event? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

/// Everything the user can change, as one record. Records compare by value,
/// so "dirty" is just `_values != _initial`.
typedef _FormValues = ({
  String title,
  String location,
  String capacity,
  String description,
  EventCategory? category,
  DateTime? day,
  TimeOfDay? time,
  bool isOnline,
});

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fields of State: created once, disposed in dispose().
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();
  final _dayText = TextEditingController();
  final _timeText = TextEditingController();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  EventCategory? _category;
  DateTime? _day;
  TimeOfDay? _time;
  bool _isOnline = false;
  bool _saving = false;
  bool _dirty = false;
  late final _FormValues _initial;

  bool get _isNew => widget.event == null;

  @override
  void initState() {
    super.initState();
    final event = widget.event ?? Event.empty();
    _title.text = event.title;
    _location.text = event.location;
    _capacity.text = '${event.capacity}';
    _description.text = event.description ?? '';
    _isOnline = event.isOnline;
    // A new event has no category or date yet: the user must choose them,
    // which is what the "required" validators check.
    if (!_isNew) {
      _category = event.category;
      _setDay(event.starts);
      _setTime(TimeOfDay.fromDateTime(event.starts));
    }
    _initial = _values;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _capacity.dispose();
    _description.dispose();
    _dayText.dispose();
    _timeText.dispose();
    _locationFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  _FormValues get _values => (
    title: _title.text,
    location: _location.text,
    capacity: _capacity.text,
    description: _description.text,
    category: _category,
    day: _day,
    time: _time,
    isOnline: _isOnline,
  );

  /// Called after every change so PopScope sees the current answer.
  void _recheckDirty() => setState(() => _dirty = _values != _initial);

  void _setDay(DateTime day) {
    _day = day;
    _dayText.text = formatDate(day);
  }

  void _setTime(TimeOfDay time) {
    _time = time;
    _timeText.text = formatClock(time.hour, time.minute);
  }

  /// Date and time as one DateTime, or null while either is missing.
  DateTime? get _starts {
    if ((_day, _time) case (final day?, final time?)) {
      return DateTime(day.year, day.month, day.day, time.hour, time.minute);
    }
    return null;
  }

  // ---------- pickers ----------

  Future<void> _pickDay() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? today,
      // Editing may keep a past date; a new event starts today at earliest.
      firstDate: _isNew ? today : DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2),
    );
    // Cancel returns null: keep the old value.
    if (picked == null || !mounted) return;
    setState(() => _setDay(picked));
    _recheckDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _setTime(picked));
    _recheckDirty();
  }

  // ---------- validators: null means valid ----------

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateLocation(String? value) {
    final location = value?.trim() ?? '';
    if (location.isEmpty) return _isOnline ? 'Enter a link' : 'Enter a place';
    if (_isOnline && !location.contains('://')) {
      return 'A link must contain ://';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse(value?.trim() ?? '');
    if (capacity == null) return 'Enter a whole number';
    if (capacity < 1 || capacity > 500) return 'From 1 to 500';
    if (widget.event case final event? when capacity < event.count) {
      return '${event.count} people are already registered';
    }
    return null;
  }

  String? _validateCategory(EventCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validateDay(String? _) => _day == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    final starts = _starts;
    if (_time == null) return 'Pick a time';
    if (_isNew && starts != null && !starts.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateDescription(String? value) =>
      (value?.length ?? 0) > 300 ? 'At most 300 characters' : null;

  // ---------- save ----------

  Future<void> _save() async {
    if (_saving) return; // a second tap while saving does nothing
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1)); // fake network
    if (!mounted) return;

    final base = widget.event ?? Event.empty();
    final description = _description.text.trim();
    final event = base.copyWith(
      id: _isNew ? 'e${DateTime.now().microsecondsSinceEpoch}' : base.id,
      title: _title.text.trim(),
      category: _category,
      starts: _starts,
      location: _location.text.trim(),
      capacity: int.tryParse(_capacity.text.trim()),
      isOnline: _isOnline,
      description: description,
      clearDescription: description.isEmpty,
    );
    // Navigator.pop ignores canPop, so Save never asks "Discard changes?".
    Navigator.pop(context, event);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    // A clean form pops at once; a dirty one is stopped and asks first.
    // The AppBar arrow and the Android back gesture both land here.
    return PopScope<Event>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: _recheckDirty,
          // Scrolls, so the keyboard never pushes Save out of reach.
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                validator: _validateTitle,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                validator: _validateCategory,
                onChanged: (value) {
                  setState(() => _category = value);
                  _recheckDirty();
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in EventCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(category.icon),
                          Text(category.label),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dayText,
                      readOnly: true,
                      onTap: _pickDay,
                      validator: _validateDay,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: _validateTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online event'),
                subtitle: const Text('The place becomes a meeting link'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() => _isOnline = value ?? false);
                  _recheckDirty();
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _location,
                focusNode: _locationFocus,
                validator: _validateLocation,
                keyboardType: _isOnline
                    ? TextInputType.url
                    : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Meeting link' : 'Place',
                  hintText: _isOnline ? 'https://meet.google.com/...' : null,
                  prefixIcon: Icon(_isOnline ? Icons.link : Icons.place),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacity,
                focusNode: _capacityFocus,
                validator: _validateCapacity,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  helperText: 'From 1 to 500',
                  prefixIcon: Icon(Icons.event_seat),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                validator: _validateDescription,
                minLines: 2,
                maxLines: 4,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTapOutside: _unfocus,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                // null while saving: the button greys out and ignores taps.
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
