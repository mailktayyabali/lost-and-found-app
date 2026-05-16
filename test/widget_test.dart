import 'package:flutter_test/flutter_test.dart';

import 'package:lost_and_found/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LostAndFoundApp());

    // Verify that our splash screen title is present
    expect(find.text('FoundIt'), findsOneWidget);
    expect(find.text('LOST & FOUND'), findsOneWidget);

    // Clean up the pending timer from SplashScreen
    await tester.pump(const Duration(seconds: 3));
  });
}
