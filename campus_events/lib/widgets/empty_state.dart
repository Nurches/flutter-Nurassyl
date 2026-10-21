import 'package:flutter/material.dart';

/// One widget for every "nothing to show" case: no match, no favourites,
/// nobody registered. The button appears only when both label and
/// callback are given.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            // Record pattern: both must be non-null, and inside the branch
            // they are already non-nullable — no `!` needed.
            if ((actionLabel, onAction) case (final label?, final onTap?)) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onTap, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
