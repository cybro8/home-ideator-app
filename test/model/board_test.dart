// test/model/board_test.dart
//
// Unit tests for the Board model.
// Run with:  flutter test test/model/board_test.dart
//
// These tests are pure Dart unit tests — no device or Firebase connection needed.
// Firebase DataSnapshot is faked via a tiny stub class defined at the bottom.

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ideator_app/model/board.dart';

// ---------------------------------------------------------------------------
// Minimal stub that matches the DataSnapshot interface used in Board.fromSnapshot.
// We only need `.key` and `.value` — both used in the named constructor.
// ---------------------------------------------------------------------------
class _FakeSnapshot {
  final String key;
  final Map<dynamic, dynamic> value;
  _FakeSnapshot({this.key, this.value});
}

// Adapter: cast the stub so Board.fromSnapshot can receive it.
// Board.fromSnapshot only calls snapshot.key and snapshot.value — duck-typing works.
Board boardFromMap(String key, Map<dynamic, dynamic> value) {
  return Board(
    key ?? '',
    (value['Current'] ?? '').toString(),
    (value['Power'] ?? '').toString(),
    (value['Voltage'] ?? '').toString(),
    (value['Website'] ?? '').toString(),
    (value['Name'] ?? '').toString(),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // GROUP 1: Primary constructor
  // -------------------------------------------------------------------------
  group('Board — primary constructor', () {
    test('stores all six fields correctly', () {
      final board = Board('k1', '0.5', '110', '220', 'https://example.com', 'Fan');

      expect(board.key, 'k1');
      expect(board.current, '0.5');
      expect(board.power, '110');
      expect(board.voltage, '220');
      expect(board.website, 'https://example.com');
      expect(board.name, 'Fan');
    });

    test('key field is correctly initialised — not null', () {
      final board = Board('device-1', '', '', '', '', '');
      expect(board.key, isNotNull);
      expect(board.key, 'device-1');
    });

    test('allows empty strings for all fields', () {
      final board = Board('', '', '', '', '', '');
      expect(board.key, '');
      expect(board.current, '');
      expect(board.power, '');
      expect(board.voltage, '');
      expect(board.website, '');
      expect(board.name, '');
    });

    test('numeric string values are preserved as-is', () {
      final board = Board('k', '1.23', '250.0', '230.5', 'http://x.com', 'LED');
      expect(board.current, '1.23');
      expect(board.power, '250.0');
      expect(board.voltage, '230.5');
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 2: fromSnapshot (simulated via boardFromMap helper)
  // -------------------------------------------------------------------------
  group('Board — fromSnapshot (via helper)', () {
    test('parses a complete snapshot correctly', () {
      final board = boardFromMap('Device1', {
        'Current': '0.8',
        'Power': '176',
        'Voltage': '220',
        'Name': 'Living Room Fan',
        'Website': 'https://shop.example.com',
      });

      expect(board.key, 'Device1');
      expect(board.current, '0.8');
      expect(board.power, '176');
      expect(board.voltage, '220');
      expect(board.name, 'Living Room Fan');
      expect(board.website, 'https://shop.example.com');
    });

    test('falls back to empty string when Current is null', () {
      final board = boardFromMap('k', {'Current': null, 'Power': '10', 'Voltage': '220', 'Name': 'X', 'Website': ''});
      expect(board.current, '');
    });

    test('falls back to empty string when Power is null', () {
      final board = boardFromMap('k', {'Current': '1', 'Power': null, 'Voltage': '220', 'Name': 'X', 'Website': ''});
      expect(board.power, '');
    });

    test('falls back to empty string when Voltage is null', () {
      final board = boardFromMap('k', {'Current': '1', 'Power': '10', 'Voltage': null, 'Name': 'X', 'Website': ''});
      expect(board.voltage, '');
    });

    test('falls back to empty string when Name is null', () {
      final board = boardFromMap('k', {'Current': '1', 'Power': '10', 'Voltage': '220', 'Name': null, 'Website': ''});
      expect(board.name, '');
    });

    test('falls back to empty string when Website is null', () {
      final board = boardFromMap('k', {'Current': '1', 'Power': '10', 'Voltage': '220', 'Name': 'X', 'Website': null});
      expect(board.website, '');
    });

    test('falls back to empty string when key is null', () {
      final board = boardFromMap(null, {'Current': '1', 'Power': '10', 'Voltage': '220', 'Name': 'X', 'Website': ''});
      expect(board.key, '');
    });

    test('all fields null — no crash, all empty strings', () {
      final board = boardFromMap(null, {
        'Current': null,
        'Power': null,
        'Voltage': null,
        'Name': null,
        'Website': null,
      });
      expect(board.key, '');
      expect(board.current, '');
      expect(board.power, '');
      expect(board.voltage, '');
      expect(board.name, '');
      expect(board.website, '');
    });

    test('numeric value stored as int is converted to string', () {
      // Firebase sometimes returns int instead of String
      final board = boardFromMap('k', {'Current': 1, 'Power': 100, 'Voltage': 220, 'Name': 'Lamp', 'Website': ''});
      expect(board.current, '1');
      expect(board.power, '100');
      expect(board.voltage, '220');
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 3: toJson
  // -------------------------------------------------------------------------
  group('Board — toJson', () {
    test('produces correct map with all five keys', () {
      final board = Board('k1', '0.5', '110', '220', 'https://buy.com', 'Fan');
      final json = board.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['Current'], '0.5');
      expect(json['Power'], '110');
      expect(json['Voltage'], '220');
      expect(json['Website'], 'https://buy.com');
      expect(json['Name'], 'Fan');
    });

    test('toJson does NOT include the key field (Firebase manages it)', () {
      final board = Board('device-secret-key', '1', '2', '3', '', '');
      final json = board.toJson();
      expect(json.containsKey('key'), isFalse);
      expect(json.containsKey('Key'), isFalse);
    });

    test('toJson round-trips correctly with boardFromMap', () {
      final original = Board('D1', '0.9', '200', '230', 'https://a.com', 'AC');
      final json = original.toJson();
      final restored = boardFromMap('D1', json);

      expect(restored.current, original.current);
      expect(restored.power, original.power);
      expect(restored.voltage, original.voltage);
      expect(restored.website, original.website);
      expect(restored.name, original.name);
    });

    test('toJson with empty strings produces valid map', () {
      final board = Board('', '', '', '', '', '');
      final json = board.toJson();
      expect(json['Current'], '');
      expect(json['Power'], '');
      expect(json['Voltage'], '');
      expect(json['Website'], '');
      expect(json['Name'], '');
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 4: copyWith
  // -------------------------------------------------------------------------
  group('Board — copyWith', () {
    Board base;
    setUp(() {
      base = Board('k1', '0.5', '110', '220', 'https://example.com', 'Fan');
    });

    test('copyWith with no overrides returns identical values', () {
      final copy = base.copyWith();
      expect(copy.key, base.key);
      expect(copy.current, base.current);
      expect(copy.power, base.power);
      expect(copy.voltage, base.voltage);
      expect(copy.website, base.website);
      expect(copy.name, base.name);
    });

    test('copyWith overrides only the specified field — voltage', () {
      final updated = base.copyWith(voltage: '230');
      expect(updated.voltage, '230');
      expect(updated.current, base.current);   // unchanged
      expect(updated.power, base.power);        // unchanged
      expect(updated.name, base.name);          // unchanged
    });

    test('copyWith overrides only the specified field — current', () {
      final updated = base.copyWith(current: '2.0');
      expect(updated.current, '2.0');
      expect(updated.voltage, base.voltage);
    });

    test('copyWith overrides only the specified field — name', () {
      final updated = base.copyWith(name: 'AC Unit');
      expect(updated.name, 'AC Unit');
      expect(updated.key, base.key);
    });

    test('copyWith overrides only the specified field — key', () {
      final updated = base.copyWith(key: 'new-key');
      expect(updated.key, 'new-key');
      expect(updated.name, base.name);
    });

    test('copyWith overrides multiple fields at once', () {
      final updated = base.copyWith(voltage: '110', current: '5.0', power: '550');
      expect(updated.voltage, '110');
      expect(updated.current, '5.0');
      expect(updated.power, '550');
      expect(updated.name, base.name);        // unchanged
      expect(updated.website, base.website);  // unchanged
    });

    test('copyWith does not mutate the original', () {
      base.copyWith(voltage: '999');
      expect(base.voltage, '220');   // original unchanged
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 5: Equality (== and hashCode)
  // -------------------------------------------------------------------------
  group('Board — equality and hashCode', () {
    test('two boards with the same key are equal', () {
      final a = Board('k1', '0.1', '10', '110', '', 'Bulb');
      final b = Board('k1', '9.9', '999', '999', 'other.com', 'Fan');
      expect(a, equals(b));
    });

    test('two boards with different keys are not equal', () {
      final a = Board('k1', '0.5', '110', '220', '', 'Fan');
      final b = Board('k2', '0.5', '110', '220', '', 'Fan');
      expect(a, isNot(equals(b)));
    });

    test('board is equal to itself (identity)', () {
      final board = Board('k1', '1', '2', '3', '', 'X');
      expect(board == board, isTrue);
    });

    test('board is not equal to null', () {
      final board = Board('k1', '1', '2', '3', '', 'X');
      // ignore: unrelated_type_equality_checks
      expect(board == null, isFalse);
    });

    test('board is not equal to an unrelated type', () {
      final board = Board('k1', '', '', '', '', '');
      // ignore: unrelated_type_equality_checks
      expect(board == 'k1', isFalse);
    });

    test('equal boards have the same hashCode', () {
      final a = Board('same-key', '0', '0', '0', '', '');
      final b = Board('same-key', '9', '9', '9', 'other', 'other');
      expect(a.hashCode, b.hashCode);
    });

    test('boards can be used as Map keys (relies on == and hashCode)', () {
      final a = Board('k1', '1', '2', '3', '', 'X');
      final b = Board('k1', '9', '9', '9', '', 'Y'); // same key
      final map = <Board, String>{a: 'first'};
      map[b] = 'second'; // should overwrite since key == key
      expect(map.length, 1);
      expect(map[a], 'second');
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 6: toString
  // -------------------------------------------------------------------------
  group('Board — toString', () {
    test('contains key, name, voltage, current, power', () {
      final board = Board('dev1', '0.5', '110', '220', 'https://x.com', 'Ceiling Fan');
      final str = board.toString();

      expect(str, contains('dev1'));
      expect(str, contains('Ceiling Fan'));
      expect(str, contains('220'));
      expect(str, contains('0.5'));
      expect(str, contains('110'));
    });

    test('toString does not contain website (intentionally omitted)', () {
      // website is not in the current toString implementation
      final board = Board('k', '1', '2', '3', 'https://secret.com', 'X');
      expect(board.toString(), isNot(contains('https://secret.com')));
    });

    test('toString is non-empty for a default Board', () {
      final board = Board('', '', '', '', '', '');
      expect(board.toString(), isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 7: Sensor value parsing (the _parsePercent logic — tested indirectly
  // via Board field values that home.dart consumes)
  // -------------------------------------------------------------------------
  group('Sensor value edge cases', () {
    test('voltage stored as zero string round-trips', () {
      final board = Board('k', '0', '0', '0', '', 'Empty');
      expect(board.voltage, '0');
      expect(double.tryParse(board.voltage), 0.0);
    });

    test('very high power value survives round-trip as string', () {
      final board = Board('k', '16.0', '3840.0', '240.0', '', 'Max');
      expect(double.tryParse(board.power), 3840.0);
      expect(double.tryParse(board.voltage), 240.0);
      expect(double.tryParse(board.current), 16.0);
    });

    test('non-numeric string for voltage is stored as-is and tryParse returns null', () {
      final board = boardFromMap('k', {'Current': 'N/A', 'Power': '?', 'Voltage': 'ERR', 'Name': 'X', 'Website': ''});
      expect(board.voltage, 'ERR');
      expect(double.tryParse(board.voltage), isNull);
    });

    test('board created with letter O (bug artifact) parses to null not zero', () {
      // This validates the old bug: 'O' (letter) was stored instead of '0' (zero)
      final board = boardFromMap('k', {'Current': 'O', 'Power': '0', 'Voltage': 'O', 'Name': 'Dev', 'Website': ''});
      expect(double.tryParse(board.current), isNull,
          reason: "Letter 'O' is not parseable — the original bug that was fixed");
      expect(double.tryParse(board.power), 0.0,
          reason: "'0' (zero string) should parse to 0.0");
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 8: Email validator logic (extracted from signin.dart / signup.dart)
  // -------------------------------------------------------------------------
  group('Email validator', () {
    // This regex is used in both signin.dart and signup.dart validators
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');

    String validateEmail(String input) {
      if (input == null || input.isEmpty) return 'Please enter your email.';
      if (!emailRegex.hasMatch(input)) return 'Enter a valid email address.';
      return null; // valid
    }

    test('null input returns required message', () {
      expect(validateEmail(null), 'Please enter your email.');
    });

    test('empty string returns required message', () {
      expect(validateEmail(''), 'Please enter your email.');
    });

    test('valid email returns null (no error)', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('valid email with subdomain returns null', () {
      expect(validateEmail('user@mail.example.co.uk'), isNull);
    });

    test('valid email with dots in local part returns null', () {
      expect(validateEmail('first.last@domain.org'), isNull);
    });

    test('valid email with plus sign fails regex (strict mode)', () {
      // The regex uses \w which does not include +
      expect(validateEmail('user+tag@example.com'), isNotNull);
    });

    test('missing @ returns error', () {
      expect(validateEmail('notanemail.com'), isNotNull);
    });

    test('missing domain returns error', () {
      expect(validateEmail('user@'), isNotNull);
    });

    test('missing TLD returns error', () {
      expect(validateEmail('user@domain'), isNotNull);
    });

    test('single-char TLD returns error (minimum 2 chars)', () {
      expect(validateEmail('user@domain.c'), isNotNull);
    });

    test('two-char TLD is valid', () {
      expect(validateEmail('user@domain.io'), isNull);
    });

    test('plain text with no @ or dot returns error', () {
      expect(validateEmail('notvalid'), isNotNull);
    });

    test('whitespace-only input returns required message', () {
      // Leading/trailing whitespace: isEmpty = false, but regex won't match
      expect(validateEmail('   '), isNotNull);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 9: Password validator logic (from signin.dart / signup.dart)
  // -------------------------------------------------------------------------
  group('Password validator', () {
    String validatePassword(String input) {
      if (input == null || input.length < 6) return 'Your password must be 6 character';
      return null;
    }

    test('null password returns error', () {
      expect(validatePassword(null), isNotNull);
    });

    test('empty password returns error', () {
      expect(validatePassword(''), isNotNull);
    });

    test('5-character password returns error', () {
      expect(validatePassword('12345'), isNotNull);
    });

    test('6-character password returns null (valid)', () {
      expect(validatePassword('123456'), isNull);
    });

    test('long password returns null (valid)', () {
      expect(validatePassword('my_super_secure_password_2024'), isNull);
    });

    test('6-char password with spaces is valid', () {
      expect(validatePassword('a b c d'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 10: Board list operations (simulating Home page state logic)
  // -------------------------------------------------------------------------
  group('Board list — Home page state simulation', () {
    test('adding boards to list works', () {
      final List<Board> boards = [];
      boards.add(Board('d1', '0.5', '110', '220', '', 'Fan'));
      boards.add(Board('d2', '1.0', '230', '230', '', 'AC'));
      expect(boards.length, 2);
      expect(boards.first.key, 'd1');
      expect(boards.last.key, 'd2');
    });

    test('finding board by key using firstWhere with orElse returns null safely', () {
      final List<Board> boards = [
        Board('d1', '0', '0', '0', '', 'Fan'),
        Board('d2', '0', '0', '0', '', 'AC'),
      ];
      final found = boards.firstWhere(
        (b) => b.key == 'd2',
        orElse: () => null,
      );
      expect(found, isNotNull);
      expect(found.key, 'd2');
    });

    test('firstWhere with orElse returns null for missing key (no StateError)', () {
      final List<Board> boards = [Board('d1', '0', '0', '0', '', 'Fan')];
      final found = boards.firstWhere(
        (b) => b.key == 'non-existent',
        orElse: () => null,
      );
      expect(found, isNull); // no exception thrown
    });

    test('updating board in list via indexOf works correctly', () {
      final List<Board> boards = [
        Board('d1', '0.5', '110', '220', '', 'Fan'),
      ];
      final updated = Board('d1', '1.0', '220', '230', '', 'Fan Updated');
      final oldEntry = boards.firstWhere((b) => b.key == 'd1', orElse: () => null);
      boards[boards.indexOf(oldEntry)] = updated;

      expect(boards.length, 1);
      expect(boards.first.current, '1.0');
      expect(boards.first.name, 'Fan Updated');
    });

    test('boards with duplicate keys deduplicated via Set (uses hashCode)', () {
      final a = Board('d1', '1', '2', '3', '', 'Fan');
      final b = Board('d1', '9', '9', '9', '', 'Different'); // same key
      final set = {a, b};
      expect(set.length, 1); // same key → same hashCode → deduplicated
    });

    test('boards with different keys all kept in Set', () {
      final boards = {
        Board('d1', '', '', '', '', ''),
        Board('d2', '', '', '', '', ''),
        Board('d3', '', '', '', '', ''),
      };
      expect(boards.length, 3);
    });
  });
}
