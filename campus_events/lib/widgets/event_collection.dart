import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_card.dart';

/// Shows events as a list on phones. Used by the events and favourites tabs.
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

  @override
  Widget build(BuildContext context) {
    // Bottom padding keeps the last card clear of the FAB.
    const padding = EdgeInsets.fromLTRB(12, 4, 12, 88);
    return ListView.separated(
      padding: padding,
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _card(events[index]),
    );
  }

  Widget _card(Event event) => EventCard(
    key: ValueKey(event.id),
    event: event,
    onTap: () => onOpen(event),
    onFavourite: () => onFavourite(event),
  );
}
