// test/setup/welcome_page_test.dart
//
// Widget tests for WelcomePage.
// Run with:  flutter test test/setup/welcome_page_test.dart
//
// These tests verify the UI structure of the welcome screen without
// requiring a real Firebase connection or device.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ideator_app/Setup/welcome_page.dart';

Widget _buildTestApp() {
  return MaterialApp(
    // Provide a fake asset bundle so Image.asset('images/icon.png') doesn't
    // crash — in test mode Flutter uses a TestDefaultBinaryMessenger that
    // returns empty data for assets not declared in the test harness.
    home: WelcomePage(),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // GROUP 1: AppBar
  // -------------------------------------------------------------------------
  group('WelcomePage — AppBar', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.text('Home Ideator'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 2: Buttons
  // -------------------------------------------------------------------------
  group('WelcomePage — Buttons', () {
    testWidgets('renders Sign In button', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders SignUp button', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.text('SignUp'), findsOneWidget);
    });

    testWidgets('two CupertinoButtons are present', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byType(CupertinoButton), findsNWidgets(2));
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 3: Navigation — tapping Sign In
  // -------------------------------------------------------------------------
  group('WelcomePage — Navigation', () {
    testWidgets('tapping Sign In navigates to a new route', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      // After navigation the Sign In AppBar title should appear
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('tapping SignUp navigates to a new route', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.tap(find.text('SignUp'));
      await tester.pumpAndSettle();
      // After navigation the Sign Up AppBar title should appear
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 4: Layout
  // -------------------------------------------------------------------------
  group('WelcomePage — Layout', () {
    testWidgets('body uses Column layout', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('welcome page renders without overflow errors', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(_buildTestApp());

      // No exceptions should be thrown
      expect(tester.takeException(), isNull);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
