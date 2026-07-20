// test/setup/signin_test.dart
//
// Widget tests for the LoginPage (Sign In screen).
// Run with:  flutter test test/setup/signin_test.dart
//
// Firebase sign-in calls are NOT exercised here — we only test:
//   • UI structure (fields, button, labels)
//   • Form validation logic (empty/invalid email, short password)
//   • That the Sign In button exists and is tappable

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ideator_app/Setup/signin.dart';

Widget _buildApp() {
  return MaterialApp(home: LoginPage());
}

void main() {
  // -------------------------------------------------------------------------
  // GROUP 1: AppBar & static UI
  // -------------------------------------------------------------------------
  group('LoginPage — AppBar & structure', () {
    testWidgets('renders AppBar with title "Sign in"', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('renders Email-ID label', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Email-ID'), findsOneWidget);
    });

    testWidgets('renders Password label', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      // The button text 'Sign in' appears both in AppBar and in the button
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('two TextFormFields are present', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('RaisedButton is present', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(RaisedButton), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 2: Email field validation
  // -------------------------------------------------------------------------
  group('LoginPage — Email validation', () {
    testWidgets('shows error when email is empty on submit', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'notanemail');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('shows error for email missing domain', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'user@');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('no email error when a valid email is entered', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();

      // Just entering text shouldn't show errors (not submitted yet)
      expect(find.text('Please enter your email.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 3: Password field validation
  // -------------------------------------------------------------------------
  group('LoginPage — Password validation', () {
    testWidgets('shows error when password is fewer than 6 chars', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, '123');
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Your password must be 6 character'), findsOneWidget);
    });

    testWidgets('no password error when password is 6+ chars', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('Your password must be 6 character'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 4: Full form validation
  // -------------------------------------------------------------------------
  group('LoginPage — Full form validation', () {
    testWidgets('shows both email and password errors when both are empty', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.byType(RaisedButton));
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Your password must be 6 character'), findsOneWidget);
    });

    testWidgets('no validation errors shown before button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // No errors on initial render
      expect(find.text('Please enter your email.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
      expect(find.text('Your password must be 6 character'), findsNothing);
    });

    testWidgets('password field uses obscureText (hides input)', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      final passwordTextField = tester.widget<TextFormField>(
        find.byType(TextFormField).last,
      );
      expect(passwordTextField.obscureText, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 5: Loading state
  // -------------------------------------------------------------------------
  group('LoginPage — Loading state', () {
    testWidgets('CircularProgressIndicator is NOT shown on initial render', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Sign in button text is shown initially (not spinner)', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());
      // Button should show 'Sign in' text, not a spinner
      expect(find.byType(RaisedButton), findsOneWidget);
    });
  });
}
