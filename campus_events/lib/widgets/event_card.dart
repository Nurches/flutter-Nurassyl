import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';
import 'event_avatar.dart';

/// The one card used by the list, the grid and the favourites tab.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavourite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Opacity(
      opacity: event.isPast ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventAvatar(event: event),
                const SizedBox(width: 12),
                // Expanded gives the column exactly the width that is left,
                // so a 60-character title wraps instead of overflowing.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.schedule,
                        text: event.isPast
                            ? '${formatDateTime(event.starts)} · ended'
                            : formatDateTime(event.starts),
                        style: muted,
                      ),
                      _InfoRow(
                        icon: event.isOnline ? Icons.link : Icons.place,
                        text: event.isOnline ? 'Online' : event.location,
                        style: muted,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: event.isFavourite
                      ? 'Remove from favourites'
                      : 'Add to favourites',
                  onPressed: onFavourite,
                  icon: Icon(
                    event.isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: event.isFavourite ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: style?.color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
