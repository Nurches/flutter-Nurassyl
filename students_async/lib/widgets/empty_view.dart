import 'package:flutter/material.dart';

/// State 3 of 4: the server answered, and the answer is "nobody".
/// A screen of its own, not a spinner: the loading is over.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No students yet', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
