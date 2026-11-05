import 'package:flutter/foundation.dart';

import 'book.dart';

/// The cart as plain Dart: no BuildContext, no widgets, no colours.
/// It runs without a screen, so it can be tested without one.
class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  /// A read-only view: outside code cannot change the cart behind its back.
  List<Book> get items => List.unmodifiable(_qty.keys);

  /// Distinct books, not copies: a quantity change does not change it.
  int get count => _qty.length;

  int get total =>
      _qty.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  int qtyOf(Book b) => _qty[b] ?? 0;

  /// The only place that knows the "no duplicates" rule.
  /// Returns false and changes nothing when the book is already there.
  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  /// +1 for a book that is already in the cart.
  void increment(Book b) {
    final q = _qty[b];
    if (q == null) return;
    _qty[b] = q + 1;
    notifyListeners();
  }

  void remove(Book b) {
    _qty.remove(b);
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
