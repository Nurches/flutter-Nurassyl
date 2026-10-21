import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../models/profile.dart';
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

  void _openDetail(Event event) {
    // Wired up together with the routes.
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
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _showAbout,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
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
