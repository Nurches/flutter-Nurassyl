import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/icon_tile.dart';
import 'events_tab.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';

/// The shell owns the app's data: the events and the profile live here,
/// tabs receive them as parameters and report changes through callbacks.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  /// Lives in MyApp's State; the shell only passes it down to the profile.
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  /// Replaces the event with the same id — a new list, never in place.
  void _replace(Event updated) {
    setState(() {
      _events = [
        for (final e in _events)
          if (e.id == updated.id) updated else e,
      ];
    });
  }

  void _updateProfile(Profile profile) => setState(() => _profile = profile);

  void _toggleFavourite(Event event) =>
      _replace(event.copyWith(isFavourite: !event.isFavourite));

  void _delete(Event event) {
    setState(() => _events = _events.where((e) => e.id != event.id).toList());
  }

  /// The detail gets the event plus callbacks: it changes shell state
  /// while staying open, so a single return value would not be enough.
  void _openDetail(Event event) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        userName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onGoToProfile: () => _selectTab(2),
      ),
    );
  }

  /// The form returns a value: it only creates, so a result is all we need.
  Future<void> _createEvent() async {
    final created = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _events = [..._events, created]);
  }

  void _showAbout() {
    Navigator.pop(context); // closes the drawer
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campus Events'),
        content: const Text(
          'Browse campus events, register with one tap and organise '
          'your own. Lab 1, Mobile Development, KBTU.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.pop(context); // closes the drawer
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All events go back to the seed and your profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    // The dialog is awaited outside setState; only the change goes inside.
    if (confirmed != true || !mounted) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_tab) {
      0 => 'Campus Events',
      1 => 'Favourites',
      _ => 'Profile',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Campus Events',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            IconTile(
              icon: const Icon(Icons.info_outline),
              title: 'About',
              onTap: _showAbout,
            ),
            IconTile(
              icon: const Icon(Icons.restore),
              title: 'Reset data',
              onTap: _resetData,
            ),
          ],
        ),
      ),
      // IndexedStack keeps every tab alive, so the search text survives
      // a trip to the profile and back.
      body: IndexedStack(
        index: _tab,
        children: [
          EventsTab(
            events: _events,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            events: _events,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            events: _events,
            onChanged: _updateProfile,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _createEvent,
              icon: const Icon(Icons.add),
              label: const Text('New event'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
