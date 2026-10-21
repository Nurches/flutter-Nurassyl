import 'package:flutter/material.dart';

import '../models/event.dart';

/// Category icon in a coloured circle, with a "FULL" / "N left" badge
/// pinned to the bottom by Positioned.
class EventAvatar extends StatelessWidget {
  const EventAvatar({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final free = event.free;
    final String? badge = event.isFull
        ? 'FULL'
        : free <= 5
        ? '$free left'
        : null;

    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: event.category.colorIn(scheme),
            foregroundColor: scheme.onSurface,
            child: Icon(event.category.icon),
          ),
          if (badge case final text?)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: event.isFull ? scheme.error : scheme.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: event.isFull ? scheme.onError : scheme.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
