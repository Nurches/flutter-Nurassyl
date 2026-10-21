import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Book')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(book.author),
          subtitle: const Text('Author'),
        ),
        ListTile(
          leading: const Icon(Icons.menu_book),
          title: Text('${book.pages}'),
          subtitle: const Text('Pages'),
        ),
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(book.year?.toString() ?? 'Year unknown'),
          subtitle: const Text('Year'),
        ),
        ListTile(
          leading: Icon(book.read ? Icons.check_circle : Icons.circle_outlined),
          title: Text(book.read ? 'Read' : 'Not read yet'),
          subtitle: const Text('Status'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
          child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _delete(context),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
