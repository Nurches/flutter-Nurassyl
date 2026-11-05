import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // Ephemeral: only this screen reads it, losing it on leave is fine.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final q = _query.trim().toLowerCase();
    final shown = books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title or author',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: shown.isEmpty
          ? const Center(child: Text('Nothing found'))
          : ListView.builder(
              itemCount: shown.length,
              itemBuilder: (context, i) => _BookRow(book: shown[i]),
            ),
    );
  }
}

/// One row is its own widget, so it has its own context and
/// subscribes on its own: subscribe low.
class _BookRow extends StatelessWidget {
  const _BookRow({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final b = book;
    debugPrint('row ${b.title}');
    // select: rebuild this row only when ITS answer flips,
    // not on every + somewhere in the cart.
    final inCart = context.select<Cart, bool>((c) => c.qtyOf(b) > 0);
    return ListTile(
      title: Text(b.title),
      subtitle: Text('${b.author} · ${b.price} ₸'),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () => _add(context),
              child: const Text('Add'),
            ),
    );
  }

  // The model answers yes/no; the widget decides what the user sees.
  void _add(BuildContext context) {
    final ok = context.read<Cart>().add(book);
    if (!ok) return; // already there: the model said no, quietly
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Added "${book.title}"')));
  }
}
