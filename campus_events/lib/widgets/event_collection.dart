import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_card.dart';

/// Shows events as a list on phones and as a grid from 600 px.
/// Used by the events and favourites tabs.
class EventCollection extends StatelessWidget {
  const EventCollection({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  static const breakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    // Bottom padding keeps the last card clear of the FAB.
    const padding = EdgeInsets.fromLTRB(12, 4, 12, 88);
    // LayoutBuilder, not MediaQuery: it reacts to the space this widget
    // actually gets (split screen, a side panel), not the whole screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return ListView.separated(
            padding: padding,
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _card(events[index]),
          );
        }
        return GridView.builder(
          padding: padding,
          // Cells at most 360 px wide: the grid adds columns as it grows.
          // A grid cell needs a height; 128 fits a two-line title.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisExtent: 128,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => _card(events[index]),
        );
      },
    );
  }

  Widget _card(Event event) => EventCard(
    key: ValueKey(event.id),
    event: event,
    onTap: () => onOpen(event),
    onFavourite: () => onFavourite(event),
  );
}
