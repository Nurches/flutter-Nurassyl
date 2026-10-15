import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:screens_lead/main.dart';

void main() {
  testWidgets('list shows students and has no back arrow', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('edit answers with a new name, back changes nothing', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    // Clean form: back without a dialog.
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('aida@kbtu.kz'), findsOneWidget);

    // Dirty form: back asks, Keep editing stays, Discard leaves.
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Akhmetova'), findsOneWidget);

    // Save: no dialog, the name comes back.
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aida Serikova');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Aida Serikova'), findsOneWidget);
  });
}
