import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('model helpers', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    expect(authors(seed).length, 5);
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X — Y, 10 pp.',
    );
  });

  testWidgets('the title count follows the filter', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Reading list (5)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pump();
    expect(find.text('Reading list (4)'), findsOneWidget);
  });

  testWidgets('an empty form shows three errors and does not pop', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Author is required'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.text('New book'), findsOneWidget);
  });
}
