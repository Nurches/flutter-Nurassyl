import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, i) => _BookRow(book: books[i]),
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
              onPressed: () => context.read<Cart>().add(b),
              child: const Text('Add'),
            ),
    );
  }
}
