import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signup_form/main.dart';

void main() {
  testWidgets('Sign up is disabled until the rules are accepted', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Empty form shows every error at once', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('I agree to the rules'));
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Email looks wrong'), findsOneWidget);
    expect(find.text('Password is too short'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Choose your birth date'), findsOneWidget);
  });
}
