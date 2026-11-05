# Practice 9 — Put It High, Subscribe Low

## Level 1 — Lift it up

**The designer's request (total price in the badge), done the honest way:**

- Constructors touched: **2**: `BooksScreen` (new `total` field) and `CartBadge` (new `total` field).
- Call sites touched: **2**: `Shell.build` passes `total:` to `BooksScreen`, and `BooksScreen.build` passes it on to `CartBadge`.
- Files touched: **3**: `lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`.
- `BooksScreen` never uses `total` itself. It is a tunnel that carries the value to the badge
  (Shell → BooksScreen → AppBar → actions → CartBadge).

**Rebuild count:** one tap on Add printed **7 lines**: `BooksScreen build` once plus
`row …` six times, one per book. `setState` in `Shell` marks everything under it dirty, so one book
added means the whole screen and every row are rebuilt.

## Level 2 — A model with no widgets

- `lib/models/cart.dart` imports only `package:flutter/foundation.dart`. The "no duplicates" rule lives in `add` and nowhere else.
- The `main()` check before `runApp` (add two, add the first again, remove one) printed
  **`1 items, 3100 ₸`** before the first frame. The lines were then deleted, and the same check now lives in
  `test/cart_test.dart`.
- `cart.items.add(books[0])` throws **`Unsupported operation: Cannot add to an unmodifiable list`**.
  Only `add` can change the cart, and `add` always notifies.
- A `BuildContext` field in `Cart` would break that `main()` check: no context exists before `runApp`.
  If the model needs a context, it is doing a widget's job.
