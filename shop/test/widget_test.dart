import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

Widget app() =>
    ChangeNotifierProvider(create: (_) => Cart(), child: const Shell());

Finder badge(String n) => find.descendant(
  of: find.byType(Badge),
  matching: find.text(n),
);

void main() {
  testWidgets('both screens see the same provided cart', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();
    expect(find.text('Added'), findsNWidgets(2));
    expect(badge('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Added'), findsOneWidget);
    expect(badge('1'), findsOneWidget);
  });

  testWidgets('+ raises the quantity and the total, not the badge', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('One more'));
    await tester.pump();
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('8400 ₸'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(badge('1'), findsOneWidget);
  });
}
