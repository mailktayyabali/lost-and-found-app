import 'package:flutter_test/flutter_test.dart';

import 'package:lost_and_found/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LostAndFoundApp());

    // Verify that our title is present
    expect(find.text('Lost and Found'), findsWidgets);
    expect(find.text('Welcome to Lost and Found App! Feature modules will go here.'), findsOneWidget);
  });
}
