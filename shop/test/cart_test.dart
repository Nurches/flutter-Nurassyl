import 'package:flutter_test/flutter_test.dart';

import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('the model answers with no widget in sight', () {
    final cart = Cart();
    cart.add(books[0]);
    cart.add(books[1]);
    expect(cart.add(books[0]), isFalse); // no duplicates
    cart.remove(books[0]);
    expect('${cart.count} items, ${cart.total} ₸', '1 items, 3100 ₸');
  });

  test('items cannot be changed from outside', () {
    final cart = Cart();
    expect(() => cart.items.add(books[0]), throwsUnsupportedError);
    expect(cart.count, 0);
  });

  test('every mutation notifies', () {
    final cart = Cart();
    var calls = 0;
    cart.addListener(() => calls++);
    cart.add(books[0]);
    cart.add(books[0]); // refused: no notify
    cart.remove(books[0]);
    cart.clear();
    expect(calls, 3);
  });

  test('quantities: count is distinct books, total is price × qty', () {
    final cart = Cart();
    cart.add(books[0]); // 4200
    cart.add(books[1]); // 3100
    cart.increment(books[0]);
    expect(cart.qtyOf(books[0]), 2);
    expect(cart.count, 2);
    expect(cart.total, 4200 * 2 + 3100);
  });
}
