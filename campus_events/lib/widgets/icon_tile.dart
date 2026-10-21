import 'package:flutter/material.dart';

/// A row with an icon (or avatar), a title and an optional subtitle.
/// Used instead of ListTile so the project needs no leading parameter anywhere (R31).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      color: selected ? theme.colorScheme.primary : null,
      fontWeight: selected ? FontWeight.bold : null,
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          spacing: 16,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
              child: icon,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle case final text?)
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            ?trailing, // null-aware element: added only when not null
          ],
        ),
      ),
    );
  }
}
