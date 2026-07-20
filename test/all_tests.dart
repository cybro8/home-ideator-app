// test/all_tests.dart
//
// Master test runner — imports and runs all test suites together.
// Run with:  flutter test test/all_tests.dart
//
// Or run all tests in the test/ directory with:
//   flutter test
//
// Individual suites can be run in isolation:
//   flutter test test/model/board_test.dart
//   flutter test test/setup/signin_test.dart
//   flutter test test/setup/signup_test.dart
//   flutter test test/setup/welcome_page_test.dart
//   flutter test test/pages/sensor_logic_test.dart

import 'model/board_test.dart' as board_tests;
import 'setup/signin_test.dart' as signin_tests;
import 'setup/signup_test.dart' as signup_tests;
import 'setup/welcome_page_test.dart' as welcome_tests;
import 'pages/sensor_logic_test.dart' as sensor_tests;

void main() {
  board_tests.main();
  signin_tests.main();
  signup_tests.main();
  welcome_tests.main();
  sensor_tests.main();
}
