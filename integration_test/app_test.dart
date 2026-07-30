import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:home_ideator_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Verify app launch, splash screen, and navigation to Welcome/Login',
        (WidgetTester tester) async {
      
      // Start the application
      app.main();
      
      // Trigger a frame
      await tester.pumpAndSettle();

      // Wait for the splash screen's duration (configured for 5 seconds in main.dart).
      // pumpAndSettle with a duration waits for any ongoing animations/timers to finish.
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Verify that the splash screen is no longer present.
      expect(find.text('Loading...'), findsNothing);

      // Depending on whether the user is logged in (from SharedPreferences),
      // they might land on the Welcome/Sign In page, or the Home page.
      // This is a foundational assertion you can expand.
      
      // For instance, you could tap on a button like:
      // await tester.tap(find.text('Sign In'));
      // await tester.pumpAndSettle();
    });
  });
}
