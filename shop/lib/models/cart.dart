import 'package:flutter/foundation.dart';

import 'book.dart';

/// The cart as plain Dart: no BuildContext, no widgets, no colours.
/// It runs without a screen, so it can be tested without one.
class Cart extends ChangeNotifier {
  final List<Book> _items = [];

  /// A read-only view: outside code cannot change the cart behind its back.
  List<Book> get items => List.unmodifiable(_items);

  int get count => _items.length;

  int get total => _items.fold(0, (sum, b) => sum + b.price);

  /// The only place that knows the "no duplicates" rule.
  /// Returns false and changes nothing when the book is already there.
  bool add(Book b) {
    if (_items.contains(b)) return false;
    _items.add(b);
    notifyListeners();
    return true;
  }

  void remove(Book b) {
    _items.remove(b);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
