import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';

/// Tab 2. Stateless: it only filters what the shell gives it.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  /// Asks the shell to switch to the events tab.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = events.where((e) => e.isFavourite).toList()
      ..sort(Event.compareForDisplay);

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet.\nTap the heart on any event.',
        actionLabel: 'Browse events',
        onAction: onBrowse,
      );
    }
    return EventCollection(
      events: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
