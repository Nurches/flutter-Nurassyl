import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/profile.dart';

/// Tab 3. Edits the profile and the theme mode; both live higher up
/// (shell and MyApp) and come back through callbacks.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Created once from the model, disposed with the State.
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);
  final _groupFocus = FocusNode();

  /// Two to five letters, a dash, two to four digits: IS-2301, CSSE-23.
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{2,4}$');

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "Reset data" in the drawer replaces the profile from outside;
    // the controllers must follow the new model.
    if (widget.profile != oldWidget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'At least 2 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final group = value?.trim() ?? '';
    if (group.isEmpty) return null; // the group is optional
    if (!_groupPattern.hasMatch(group)) return 'Format: IS-2301';
    return null;
  }

  void _saveName(String value) {
    if (_validateName(value) != null) return;
    widget.onChanged(widget.profile.copyWith(name: value.trim()));
    _groupFocus.requestFocus();
  }

  void _saveGroup(String value) {
    if (_validateGroup(value) != null) return;
    widget.onChanged(widget.profile.copyWith(group: value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.profile;
    // Computed on every build from the shell's list — never stored.
    final lists = profile.hasName
        ? widget.events.where((e) => e.contains(profile.name)).length
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 40,
          child: Text(
            profile.hasName ? profile.name.characters.first.toUpperCase() : '?',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.hasName ? 'You are on $lists lists' : 'Add your name below',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: _saveName,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Next to save',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _group,
          focusNode: _groupFocus,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _saveGroup,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'IS-2301',
            helperText: 'Press Done to save',
            prefixIcon: Icon(Icons.groups),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
