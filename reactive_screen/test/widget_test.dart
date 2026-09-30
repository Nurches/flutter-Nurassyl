import 'package:flutter_test/flutter_test.dart';

import 'package:reactive_screen/main.dart';

void main() {
  testWidgets('Tapping the card increments the count', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('A screen that reacts'), findsOneWidget);

    await tester.tap(find.text('Tap this card'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
