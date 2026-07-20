// test/pages/sensor_logic_test.dart
//
// Pure unit tests for the sensor gauge logic extracted from home.dart.
// This covers _parsePercent() and related display logic.
// Run with:  flutter test test/pages/sensor_logic_test.dart

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Extracted from home.dart: _parsePercent()
// Tests this function in isolation without needing a widget tree.
// ---------------------------------------------------------------------------
double parsePercent(String value, {double maxValue = 100}) {
  if (value == null || value.isEmpty) return 0.0;
  final double parsed = double.tryParse(value) ?? 0.0;
  return (parsed / maxValue).clamp(0.0, 1.0);
}

void main() {
  // -------------------------------------------------------------------------
  // GROUP 1: parsePercent — null / empty inputs
  // -------------------------------------------------------------------------
  group('parsePercent — null / empty inputs', () {
    test('null value returns 0.0', () {
      expect(parsePercent(null), 0.0);
    });

    test('empty string returns 0.0', () {
      expect(parsePercent(''), 0.0);
    });

    test('whitespace string is non-parseable → returns 0.0', () {
      expect(parsePercent('   '), 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 2: parsePercent — non-numeric strings
  // -------------------------------------------------------------------------
  group('parsePercent — non-numeric strings', () {
    test('letter "O" (old bug artifact) returns 0.0 not a crash', () {
      expect(parsePercent('O'), 0.0);
    });

    test('random text returns 0.0', () {
      expect(parsePercent('N/A'), 0.0);
    });

    test('question mark returns 0.0', () {
      expect(parsePercent('?'), 0.0);
    });

    test('partial number like "12abc" returns 0.0', () {
      expect(parsePercent('12abc'), 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 3: parsePercent — Voltage (maxValue: 240)
  // -------------------------------------------------------------------------
  group('parsePercent — Voltage (max 240V)', () {
    test('0V → 0.0', () {
      expect(parsePercent('0', maxValue: 240), 0.0);
    });

    test('120V → 0.5', () {
      expect(parsePercent('120', maxValue: 240), closeTo(0.5, 0.001));
    });

    test('240V (max) → 1.0', () {
      expect(parsePercent('240', maxValue: 240), 1.0);
    });

    test('above max (300V) is clamped to 1.0', () {
      expect(parsePercent('300', maxValue: 240), 1.0);
    });

    test('typical household voltage 220V', () {
      expect(parsePercent('220', maxValue: 240), closeTo(0.916, 0.001));
    });

    test('typical household voltage 230V', () {
      expect(parsePercent('230', maxValue: 240), closeTo(0.958, 0.001));
    });

    test('negative voltage clamped to 0.0', () {
      expect(parsePercent('-10', maxValue: 240), 0.0);
    });

    test('decimal voltage 110.5V', () {
      expect(parsePercent('110.5', maxValue: 240), closeTo(0.460, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 4: parsePercent — Current (maxValue: 16)
  // -------------------------------------------------------------------------
  group('parsePercent — Current (max 16A)', () {
    test('0A → 0.0', () {
      expect(parsePercent('0', maxValue: 16), 0.0);
    });

    test('8A → 0.5', () {
      expect(parsePercent('8', maxValue: 16), closeTo(0.5, 0.001));
    });

    test('16A (max) → 1.0', () {
      expect(parsePercent('16', maxValue: 16), 1.0);
    });

    test('above max (20A) is clamped to 1.0', () {
      expect(parsePercent('20', maxValue: 16), 1.0);
    });

    test('typical CFL current 0.18A', () {
      expect(parsePercent('0.18', maxValue: 16), closeTo(0.011, 0.001));
    });

    test('typical fan current 0.5A', () {
      expect(parsePercent('0.5', maxValue: 16), closeTo(0.031, 0.001));
    });

    test('negative current clamped to 0.0', () {
      expect(parsePercent('-5', maxValue: 16), 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 5: parsePercent — Power (maxValue: 3840)
  // -------------------------------------------------------------------------
  group('parsePercent — Power (max 3840W)', () {
    test('0W → 0.0', () {
      expect(parsePercent('0', maxValue: 3840), 0.0);
    });

    test('1920W → 0.5', () {
      expect(parsePercent('1920', maxValue: 3840), closeTo(0.5, 0.001));
    });

    test('3840W (max) → 1.0', () {
      expect(parsePercent('3840', maxValue: 3840), 1.0);
    });

    test('above max (5000W) is clamped to 1.0', () {
      expect(parsePercent('5000', maxValue: 3840), 1.0);
    });

    test('typical CFL 9W', () {
      expect(parsePercent('9', maxValue: 3840), closeTo(0.0023, 0.0001));
    });

    test('typical ceiling fan ~75W', () {
      expect(parsePercent('75', maxValue: 3840), closeTo(0.0195, 0.001));
    });

    test('typical AC 1.5 ton ~1500W', () {
      expect(parsePercent('1500', maxValue: 3840), closeTo(0.390, 0.001));
    });

    test('negative power clamped to 0.0', () {
      expect(parsePercent('-100', maxValue: 3840), 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 6: parsePercent — generic / boundary behaviour
  // -------------------------------------------------------------------------
  group('parsePercent — boundary and generic', () {
    test('result is always between 0.0 and 1.0 inclusive', () {
      final values = ['0', '50', '100', '200', '-10', '999'];
      for (final v in values) {
        final result = parsePercent(v, maxValue: 100);
        expect(result, inInclusiveRange(0.0, 1.0),
            reason: 'parsePercent("$v") out of [0,1] range');
      }
    });

    test('exactly 50% of maxValue → 0.5', () {
      expect(parsePercent('50', maxValue: 100), 0.5);
      expect(parsePercent('120', maxValue: 240), closeTo(0.5, 0.0001));
      expect(parsePercent('8', maxValue: 16), 0.5);
    });

    test('default maxValue of 100 works', () {
      expect(parsePercent('75'), closeTo(0.75, 0.001));
    });

    test('very small positive value is > 0', () {
      expect(parsePercent('0.001', maxValue: 100), greaterThan(0.0));
    });
  });

  // -------------------------------------------------------------------------
  // GROUP 7: Rating Generator — compute_rating logic (Dart mirror)
  //
  // We mirror the Python compute_rating() logic here in Dart so that the
  // exact same boundary conditions are covered in both languages.
  // -------------------------------------------------------------------------
  int computeRating(int totalMinutes) {
    int rating = 0;
    final int totalHours = totalMinutes ~/ 60;

    if (totalHours <= 23) {
      rating = 1;
    } else if (totalHours >= 24 && totalHours <= 8760) {
      final int totalDays = totalHours ~/ 24;
      if (totalDays == 1) {
        rating = 2;
      } else if (totalDays < 90) {
        rating = 4;
      } else if (totalDays >= 90 && totalDays <= 183) {
        rating = 8;
      } else {
        rating = 9;
      }
    } else {
      rating = 9;
    }
    return rating;
  }

  group('computeRating — device health rating logic', () {
    test('0 minutes → rating 1 (0 hrs is ≤23)', () {
      expect(computeRating(0), 1);
    });

    test('30 minutes → rating 1', () {
      expect(computeRating(30), 1);
    });

    test('23 hours (1380 min) → rating 1', () {
      expect(computeRating(1380), 1);
    });

    test('exactly 1 day (1440 min) → rating 2', () {
      // This was the broken case — rating == 2 vs rating = 2
      expect(computeRating(1440), 2);
    });

    test('2 days (2880 min) → rating 4', () {
      expect(computeRating(2880), 4);
    });

    test('89 days (128160 min) → rating 4', () {
      expect(computeRating(128160), 4);
    });

    test('90 days (129600 min) → rating 8', () {
      expect(computeRating(129600), 8);
    });

    test('183 days (263520 min) → rating 8', () {
      expect(computeRating(263520), 8);
    });

    test('184 days (264960 min) → rating 9', () {
      expect(computeRating(264960), 9);
    });

    test('366 days (527040 min) → rating 9 (over 1 year)', () {
      expect(computeRating(527040), 9);
    });

    test('rating is always in range [0, 9]', () {
      final testMinutes = [0, 30, 1440, 5000, 129600, 264960, 527040, 1000000];
      for (final m in testMinutes) {
        final r = computeRating(m);
        expect(r, inInclusiveRange(0, 9),
            reason: 'computeRating($m) = $r is out of [0,9]');
      }
    });
  });
}
