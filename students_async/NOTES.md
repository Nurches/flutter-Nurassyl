# Practice 10 — The Data Arrives Later

How the console lines below were collected: in widget tests with fake time, with `print`/`debugPrint` collected
in a zone and errors taken from `FlutterError.onError` and the zone's uncaught-error handler. Each
"break it on purpose" variant was a copy of the screen inside a temporary test, so `lib/` never held broken code.
On a real device the engine adds its own `E/flutter … [ERROR:…]` prefix to unhandled errors. The message text is the same.

## Level 1 — A fake API that fails, and the order of events

Experiment in `main()` before `runApp`:

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

| | Order |
|---|---|
| **Predicted** | `A`, `C`, `fetchStudents #1`, first frame, (2 s later) `B`, `6 students` |
| **Actual** | `A` · `C` · `fetchStudents #1` · *[first frame]* · `B` · `6 students` |

- Nothing waited for the timer. `main()` ran to the end, the loop drew the first frame, and `B` and `6 students`
  arrived two seconds later as events. `B` comes first because its timer was registered first.
- `fetchStudents #1` comes **before** the first frame: an `async` function runs synchronously up to its first `await`,
  so `calls++` and the `debugPrint` happen during the call itself.

**Three calls in a row:**

```
fetchStudents #1
fetchStudents #2
fetchStudents #3
6 students
6 students
Unhandled Exception: Instance of 'NoConnectionException'
```

The app keeps running as if nothing happened, because nobody listened to the third Future's error.

> Note: the call number is stored **before** the `await` (`final call = ++calls;`). Checking `calls % 3` *after*
> the delay, as written in the task text, makes all three calls see `calls == 3` and all three fail.

**`sleep` instead of `await Future.delayed`:** the `fetchStudents()` call itself returned after **2001 ms**.
`main()` was stuck on that line, so `runApp` and the first frame waited two seconds. `sleep` blocks the loop,
while `await` hands control back to it. Restored, and the `main()` experiments were deleted.

## Level 2 — Four states by hand

- Load: spinner → 6 students after 2 s. Reload, Reload → the third request shows **Could not load students** + Retry.
  Retry → the list again. Console: `fetchStudents #1` … `#4`.
- Back during the two seconds, with the guards: nothing in the console after `fetchStudents #1`, and no exception.
  `mounted` was false when the reply arrived.
- **Without both `if (!mounted) return;`**, Back within two seconds:

```
setState() called after dispose(): _NoMountedState#1fd79(lifecycle state: defunct, not mounted)
```

(`_NoMountedState` is the name of the guard-less copy. In the app the line names `_StudentsScreenState`.)

## Level 3 — FutureBuilder, and the Switch that proves it

| `future:` | 10 Switch flips → console | spinner during the flips |
|---|---|---|
| `_future` (field set in `initState`) | `fetchStudents #1` only | **0 of 10** flips |
| `_api.fetchStudents()` inline in `build` | `#2 #3 … #11`, one per rebuild (`#3`, `#6`, `#9` fail) | **10 of 10** flips |

- **Server down** (a copy of the API that always throws):
  - `hasError` checked first → error view + Retry.
  - `!hasData` checked first (the lecture's wrong version) → still a **spinner after 10 s**. A failed Future has no data,
    so "no data → loading" catches the error before the error check is reached.
- `_retry` is the only place that creates a new Future: `setState(() => _future = _api.fetchStudents())`.
  That is why `_future` is `late` but not `final`.

## Level 4 — The countdown

| Experiment | Console after Back at 7 |
|---|---|
| **B with `_sub.cancel()`** | `tick 10 · tick 9 · tick 8 · tick 7`, then **nothing** |
| **B without `cancel()`** | `tick 6 · tick 5 · … · tick 0` keeps coming with nobody on screen, plus **7 ×** `setState() called after dispose(): _NoCancelState#3942d(lifecycle state: defunct, not mounted)` — one per tick |
| **A (StreamBuilder, no `cancel()` in my code)** | `tick 10 · tick 9 · tick 8 · tick 7`, then **nothing** |

- With `cancel()` the generator was suspended at `await Future.delayed`. When it resumed, `yield` saw a cancelled
  subscription and returned, so `tick 6` was never printed.
- Without it, the same error as in Level 2 comes from a different messenger (a stream instead of a Future),
  and the generator runs to 0. That is the leak.
- StreamBuilder unsubscribes in its own `dispose`, so it cancelled for me.

## Level 5 — Errors that do not vanish

**The way the AI writes it:** `onPressed: () { _api.save(n); Navigator.pop(context); }`

- `flutter analyze` with `unawaited_futures: true` says **nothing** about this line. The lint only checks `async` bodies,
  and this closure is not `async`. After changing it to `() async { _api.save(n); … }` the lint fires:
  `info • Missing an 'await' for the 'Future' computed by this expression • unawaited_futures`.
- Tap 1 pops (save #1 succeeds). Tap 2 **also pops**, and one second later the console prints:

```
Unhandled Exception: Bad state: server rejected 6
```

**The user saw a success.**

**The honest version** (`_save` in `students_screen.dart`): `await` + `try / on StateError`, `context.mounted` after the await,
`Navigator.pop` only on success, a `SnackBar` with `e.message` only on failure.

- Measured: save #1 → back on Home. Save #2 → stays on the screen with the SnackBar **server rejected 6**.
- While the request is in flight, `_saving` is `true`. The FAB has `onPressed: null` and shows a small spinner.
  Two fast taps → **one** request (the next opening got save #2, not #3).

## Decisions

- **Save counter on the "server".** Each screen creates its own `FakeApi()`, as the task says, so `calls` starts at #1
  on every screen. Saves are counted in a `static` field: a successful Save pops the screen, so a per-instance counter
  would reset, and the failing second save would never be seen.
- **Reload button** in both AppBars. It is the way to reach the third request ("Retry three times") without leaving the screen.
- **`unawaited(_load())` in `initState` and `unawaited(_sub.cancel())` in `dispose`.** Both are still called without `await`,
  as the task says. `unawaited()` marks this as deliberate, so `lib/` has no silently dropped Future. `_load` catches its own errors.
- **`_save(BuildContext context)`** takes the button's context. Inside a `State`, the analyzer treats `context.mounted`
  on the State's own `context` as an "unrelated mounted check" (`use_build_context_synchronously`). With a context
  parameter, the method is a real callback guarding its own context, which is the point of the lesson.
- The four views are separate `StatelessWidget`s in `lib/widgets/`, and both student screens reuse them.
