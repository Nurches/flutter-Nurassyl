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

## Level 3 — The same app with provider

`grep -r "cart:" lib/` finds nothing. No widget between the provider and the badge knows the cart exists.
(The Level 1 total in the badge has been dropped. With provider, the same request would be one line in `CartBadge`
and **0 constructors**.)

**The loud one.** Using `context.watch<Cart>().add(b)` in the Add button's `onPressed` throws on tap:

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);

It is unsupported because may pointlessly rebuild the widget associated to the
event handler, when the widget tree doesn't care about the value.
```

**The silent one.** Using `context.read<Cart>().count` in `CartBadge.build` gives **no error at all**. It compiles and runs,
and the badge is frozen at **0** forever, even after books are added, because the badge never said "I depend on the cart".
`read` is a verb of `onPressed`, and `watch` is a verb of `build`.

## Level 4 — Scope: select and Consumer

Measured with `debugPrint('badge build')` / `debugPrint('row …')`. One book in the cart, the Cart screen open,
**+** pressed three times, then the book removed:

| Badge subscribes with | 3 × **+** | remove a book |
|---|---|---|
| `context.watch<Cart>().count` | **3** badge builds | 1 |
| `context.select<Cart, int>((c) => c.count)` | **0** badge builds | 1 |

Same model, same taps, one line changed in one widget. `watch` rebuilds on every `notifyListeners()`.
`select` rebuilds only when the selected value (`count`) actually changes, and **+** does not change it.

- The Books rows use `select<Cart, bool>((c) => c.qtyOf(b) > 0)` too: 3 × **+** rebuilt **0** rows. Removing the
  book rebuilt **1** row, the one whose answer flipped back to "Add".
- **Watch moved up on purpose** (`context.watch<Cart>()` in `BooksScreen.build`): 3 × **+** on the *Cart* screen
  rebuilt `BooksScreen` **3** times and **18** rows (6 × 3), all on a screen nobody is looking at.
  Subscribe where the value is shown, not where it is convenient.
- The total line is a `Consumer<Cart>` whose `child` is `const _TotalLabel()` (icon + "Total"). On every notify
  the builder runs and only the number changes. `total label build` printed **0** times during the taps,
  because the label was built once.

DevTools → Performance → *Track widget builds* shows the same picture. The numbers above come from the
console lines, measured in a widget test that collects `debugPrint` output.

## Level 5 — Logic on the right side of the line

- **Added SnackBar.** `Cart.add` returns a `bool`, and the row decides:
  `final ok = context.read<Cart>().add(b); if (ok) ScaffoldMessenger…showSnackBar(…)`.
  When the model says no (the book is already there), nothing is shown.
- **Clear cart.** The question lives in the widget: `showDialog<bool>` with an `AlertDialog`, then
  `context.mounted` after the `await`. The clearing lives in the model, and `context.read<Cart>().clear()` runs only on `true`.
  The button is disabled while the cart is empty (`select` on `count == 0`).
- `models/` has no `BuildContext`, `SnackBar`, `Navigator`, colour or widget. `cart.dart` imports only `foundation.dart`.

### Where does it live?

| Value | Home | Why |
|---|---|---|
| The cart | **provided** (`ChangeNotifierProvider<Cart>` above `MaterialApp`) | Two routes and the badge read it, it changes from both screens, and it must survive navigation. |
| Search text in the Books AppBar | **ephemeral** (`_query` in `_BooksScreenState`) | Only the Books list reads it. Losing it when the screen goes away is fine. |
| Cart total expanded / collapsed | **ephemeral** (a `bool` in the Cart screen's `State`) | Pure view state of one widget. No other screen cares, and the model must not know about layout. |
| Theme mode (a dark-mode switch) | **lifted** (in the widget that builds `MaterialApp`), or provided if a deep settings screen flips it | `MaterialApp` itself needs it, so it must live above `MaterialApp`. It is app-wide, not part of the cart. |
