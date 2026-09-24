import 'package:flutter_test/flutter_test.dart';

import 'package:profile_screen/data.dart';
import 'package:profile_screen/info_row.dart';
import 'package:profile_screen/main.dart';

void main() {
  testWidgets('Profile screen shows header and all facts', (tester) async {
    await tester.pumpWidget(const ProfileApp());

    expect(find.text('My profile'), findsOneWidget);
    expect(find.text(myName), findsOneWidget);
    expect(find.byType(InfoRow), findsNWidgets(facts.length));
  });
}
