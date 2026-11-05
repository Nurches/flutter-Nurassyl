import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop/main.dart';

void main() {
  testWidgets('both screens see the same lifted list', (tester) async {
    await tester.pumpWidget(const Shell());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();
    expect(find.text('Added'), findsNWidgets(2));
    expect(find.text('2 · 7300 ₸'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Added'), findsOneWidget);
    expect(find.text('1 · 3100 ₸'), findsOneWidget);
  });
}
