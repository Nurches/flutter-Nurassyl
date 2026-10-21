import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// Pushed from a card. Keeps its own copy of the event so it can redraw
/// at once, and reports every change to the shell through the callbacks.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Created once, cancelled in dispose — otherwise it would keep calling
    // setState on a dead State after we leave the screen.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _me => widget.args.userName.trim();

  /// Local copy first (instant redraw), then up to the shell.
  void _update(Event event) {
    setState(() => _event = event);
    widget.args.onChanged(event);
  }

  Future<void> _register() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _goToProfile),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register?'),
        content: Text('Add $_me to "${_event.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _update(_event.register(_me));
  }

  void _unregister() => _update(_event.unregister(_me));

  /// The tab switch is the shell's job; we only leave and ask for it.
  void _goToProfile() {
    if (mounted) Navigator.pop(context);
    widget.args.onGoToProfile();
  }

  Future<void> _edit() async {
    // Filled in together with the form screen.
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${_event.title}" will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final registered = _me.isNotEmpty && _event.contains(_me);
    // onPressed: null disables the button: nothing to do when it is full or
    // over. On the list already, the action becomes its opposite.
    final (VoidCallback? action, String label) = switch (_event) {
      _ when registered => (_unregister, 'Cancel registration'),
      Event(isPast: true) => (null, 'Event has ended'),
      Event(isFull: true) => (null, 'No places left'),
      _ => (_register, 'Register'),
    };

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_event.title),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (choice) => switch (choice) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(event: _event, countdown: Countdown.of(_event, _now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                // Rebuilt with the screen, so the count is always live.
                Tab(text: 'Attendees (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(event: _event),
                  _AttendeesTab(event: _event, me: _me),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: registered
              ? OutlinedButton.icon(
                  onPressed: action,
                  icon: const Icon(Icons.event_busy),
                  label: Text(label),
                )
              : FilledButton.icon(
                  onPressed: action,
                  icon: const Icon(Icons.event_available),
                  label: Text(label),
                ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event, required this.countdown});

  final Event event;
  final Countdown countdown;

  /// Exhaustive switch over the sealed class: a fourth subclass would
  /// not compile until it is handled here.
  String get _countdownText => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started(:final elapsed) =>
      'Live · ends in ${formatDuration(Event.length - elapsed)}',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/event_header.png', fit: BoxFit.cover),
          ),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: event.category.colorIn(scheme),
              foregroundColor: scheme.onSurface,
              child: Icon(event.category.icon, size: 40),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(
              avatar: Icon(event.category.icon),
              label: Text(event.category.label),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(_countdownText),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    // Record destructuring: two named values out of one getter.
    final (:taken, :free) = event.places;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(event.starts)),
          subtitle: Text('Until ${formatTime(event.ends)}'),
        ),
        ListTile(
          leading: Icon(event.isOnline ? Icons.link : Icons.place),
          title: Text(event.location),
          subtitle: Text(event.isOnline ? 'Online meeting link' : 'On campus'),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat),
          title: Text('$taken of ${event.capacity} places taken'),
          subtitle: Text(event.isFull ? 'Full' : '$free free'),
        ),
        // Shown only when present: collection if with a null-check pattern.
        if (event.description case final text?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
      ],
    );
  }
}

class _AttendeesTab extends StatelessWidget {
  const _AttendeesTab({required this.event, required this.me});

  final Event event;
  final String me;

  @override
  Widget build(BuildContext context) {
    if (event.count == 0) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody is on the list yet',
      );
    }
    return ListView(
      children: [
        for (final name in event.attendees)
          ListTile(
            selected: name == me,
            leading: CircleAvatar(child: Text(name.characters.first)),
            title: Text(name),
            trailing: name == me ? const Text('You') : null,
          ),
      ],
    );
  }
}
