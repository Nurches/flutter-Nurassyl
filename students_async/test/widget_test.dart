import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';
import 'package:students_async/main.dart';
import 'package:students_async/widgets/error_view.dart';
import 'package:students_async/widgets/loading_view.dart';

/// Runs [body] with debugPrint collected into a list — the "console".
void testConsole(
  String name,
  Future<void> Function(WidgetTester t, List<String> console) body,
) => testWidgets(name, (t) async {
  final console = <String>[];
  final original = debugPrint;
  debugPrint = (m, {wrapWidth}) => console.add(m ?? '');
  FakeApi.resetSaves();
  try {
    await body(t, console);
  } finally {
    debugPrint = original;
  }
});

Future<void> go(WidgetTester t, String entry) async {
  await t.pumpWidget(const App());
  await t.tap(find.text(entry));
  await t.pump();
  await t.pump(const Duration(seconds: 1)); // the page transition
}

Future<void> back(WidgetTester t) async {
  t.state<NavigatorState>(find.byType(Navigator)).pop();
  await t.pump();
  await t.pump(const Duration(milliseconds: 850));
  await t.pump(); // the frame that disposes the route
}

void main() {
  testWidgets('home has three ways in', (t) async {
    await t.pumpWidget(const App());
    expect(find.text('By hand'), findsOneWidget);
    expect(find.text('FutureBuilder'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
  });

  testConsole('by hand: loading -> list, third load fails, Retry works', (
    t,
    console,
  ) async {
    await go(t, 'By hand');
    expect(find.byType(LoadingView), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // Aruzhan has no gpa

    for (var i = 0; i < 2; i++) {
      await t.tap(find.byIcon(Icons.refresh));
      await t.pump();
      await t.pump(const Duration(seconds: 2));
    }
    expect(find.byType(ErrorView), findsOneWidget);
    await t.tap(find.text('Retry'));
    await t.pump();
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(console, [for (var i = 1; i <= 4; i++) 'fetchStudents #$i']);
  });

  testConsole('by hand: Back during loading is silent', (t, console) async {
    await t.pumpWidget(const App());
    await t.tap(find.text('By hand'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    await back(t);
    await t.pump(const Duration(seconds: 3)); // the reply arrives to nobody
    expect(t.takeException(), isNull);
    expect(console, ['fetchStudents #1']);
  });

  testConsole('FutureBuilder: ten Switch flips, one request', (
    t,
    console,
  ) async {
    await go(t, 'FutureBuilder');
    await t.pump(const Duration(seconds: 1));
    for (var i = 0; i < 10; i++) {
      await t.tap(find.byType(Switch));
      await t.pump();
      expect(find.byType(LoadingView), findsNothing);
    }
    expect(console, ['fetchStudents #1']);
  });

  testConsole('countdown B: Back at 7 stops the ticks', (t, console) async {
    await go(t, 'Countdown');
    console.clear(); // version A ran for a second before B was chosen
    await t.tap(find.text('B · listen'));
    await t.pump();
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    expect(find.text('7'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 100));
    await back(t);
    await t.pump(const Duration(seconds: 10));
    expect(console, ['tick 10', 'tick 9', 'tick 8', 'tick 7']);
  });

  testConsole('Save: success pops, failure shows a SnackBar', (
    t,
    console,
  ) async {
    Future<void> openAndSave() async {
      await go(t, 'By hand');
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 500)); // FAB scale-in
      final fab = find.byType(FloatingActionButton);
      await t.tap(fab);
      await t.pump();
      await t.tap(fab, warnIfMissed: false); // a fast second tap
      await t.pump();
      expect(
        find.descendant(
          of: fab,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
    }

    await openAndSave(); // save #1: ok
    expect(find.text('By hand'), findsOneWidget); // popped home

    await openAndSave(); // save #2 (the double tap above was one request)
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.text('Students · by hand'), findsOneWidget); // still here
  });
}
