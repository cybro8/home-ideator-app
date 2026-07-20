// test/setup/signup_test.dart
//
// Widget tests for the SignUp screen.
// Run with:  flutter test test/setup/signup_test.dart
//
// Firebase account creation is NOT exercised here — we only test:
//   • UI structure (fields, button, labels, AppBar)
//   • Form validation (email format, password length)
//   • Correct button label ("Sign Up", not "Sign in")

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ideator_app/Setup/signup.dart';

Widget _buildApp() {
  return MaterialApp(home: SignUp());
}

void main() {
  // -------------------------------------------------------------------------
  // GROUP 1: AppBar & static UI
  // -------------------------------------------------------------------------
  group('SignUp — AppBar & structure', () {
    testWidgets('renders AppBar with title "Sign Up"', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Sign Up'), findsWidgets); // AppBar + button
    });

    testWidgets('renders Email-ID label', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Email-ID'), findsOneWidget);
    });

    testWidgets('renders Password label', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('button label is "Sign Up" — not "Sign in" (bug fix verification)', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      // The fixed label must be "Sign Up", not "Sign in"
      expect(find.text('Sign Up'), findsWidgets);
      // "Sign in" text must NOT appear anywhere on this screen
      expect(find.text('Sign in'), findsNothing);
    });

    testWidgets('two TextFormFields are present', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('one RaisedButton is present', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(RaisedButton), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 2: Email validation
  // -------------------------------------------------------------------------
  group('SignUp — Email validation', () {
    testWidgets('shows error when email is empty on submit', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
    });

    testWidgets('shows error for email without @ sign', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('shows error for email without TLD', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'user@domain');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('no email error for a valid email address', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'securepass');
      await tester.pump();

      expect(find.text('Please enter your email.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 3: Password validation
  // -------------------------------------------------------------------------
  group('SignUp — Password validation', () {
    testWidgets('shows error when password has fewer than 6 characters', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'abc');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Your password must be 6 character'), findsOneWidget);
    });

    testWidgets('no password error for 6+ character password', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'mypassword');
      await tester.pump();

      expect(find.text('Your password must be 6 character'), findsNothing);
    });

    testWidgets('password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final passwordField = tester.widget<TextFormField>(
        find.byType(TextFormField).last,
      );
      expect(passwordField.obscureText, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 4: Combined form validation
  // -------------------------------------------------------------------------
  group('SignUp — Combined form validation', () {
    testWidgets('shows both errors when both fields are empty on submit', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Your password must be 6 character'), findsOneWidget);
    });

    testWidgets('no errors shown before any interaction', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      expect(find.text('Please enter your email.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
      expect(find.text('Your password must be 6 character'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 5: Loading state
  // -------------------------------------------------------------------------
  group('SignUp — Loading state', () {
    testWidgets('CircularProgressIndicator is NOT shown initially', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('"Sign Up" text is visible on button before loading', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Sign Up'), findsWidgets);
    });
  });
}
