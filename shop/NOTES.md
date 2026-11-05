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
