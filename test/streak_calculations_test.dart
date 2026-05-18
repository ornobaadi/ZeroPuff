import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/streak_calculations.dart';

void main() {
  group('StreakCalculations', () {
    test('clamps smoke-free days when quit date is in the future', () {
      final days = StreakCalculations.smokeFreeDays(
        quitDate: DateTime(2026, 5, 20),
        now: DateTime(2026, 5, 18),
      );

      expect(days, 0);
    });

    test('calculates whole smoke-free days from quit date', () {
      final days = StreakCalculations.smokeFreeDays(
        quitDate: DateTime(2026, 5, 10, 9),
        now: DateTime(2026, 5, 18, 8),
      );

      expect(days, 7);
    });

    test('counts consecutive honesty check-ins ending today', () {
      final streak = StreakCalculations.honestyStreakDays(
        today: DateTime(2026, 5, 18, 21),
        checkInDates: {
          DateTime(2026, 5, 18, 9),
          DateTime(2026, 5, 17, 23),
          DateTime(2026, 5, 16),
          DateTime(2026, 5, 14),
        },
      );

      expect(streak, 3);
    });

    test('returns zero when today has no honesty check-in', () {
      final streak = StreakCalculations.honestyStreakDays(
        today: DateTime(2026, 5, 18),
        checkInDates: {DateTime(2026, 5, 17), DateTime(2026, 5, 16)},
      );

      expect(streak, 0);
    });
  });
}
