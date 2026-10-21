import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_category.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';

/// Tab 1. Owns only UI state (search text, chips); the events themselves
/// come from the shell and changes go back up through callbacks.
class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _search = TextEditingController();
  String _query = '';
  EventCategory? _category; // null means "All"
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    // where() builds a new list and sort() works on that copy —
    // the shell's list is never reordered.
    final visible =
        widget.events
            .where((e) => _category == null || e.category == _category)
            .where((e) => _showPast || !e.isPast)
            .where((e) => e.title.toLowerCase().contains(query))
            .toList()
          ..sort(Event.compareForDisplay);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in EventCategory.values)
                ChoiceChip(
                  avatar: Icon(category.icon),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
        ),
        // The list takes whatever height is left — no shrinkWrap,
        // no fixed height.
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No events match your search',
                  actionLabel: _query.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : EventCollection(
                  events: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
