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

    test('counts smoke-free calendar streak until a relapse day', () {
      final streak = StreakCalculations.smokeFreeCalendarStreakDays(
        quitDate: DateTime(2026, 5, 10, 9),
        today: DateTime(2026, 5, 18, 21),
        smokingDates: {DateTime(2026, 5, 14, 22), DateTime(2026, 5, 12, 10)},
      );

      expect(streak, 4);
    });

    test('returns zero smoke-free calendar streak after smoking today', () {
      final streak = StreakCalculations.smokeFreeCalendarStreakDays(
        quitDate: DateTime(2026, 5, 10),
        today: DateTime(2026, 5, 18, 21),
        smokingDates: {DateTime(2026, 5, 18, 8)},
      );

      expect(streak, 0);
    });

    test('honesty streak includes smoke logs as honest activity', () {
      final streak = StreakCalculations.honestyStreakDaysFromActivity(
        today: DateTime(2026, 5, 18, 21),
        checkInDates: {DateTime(2026, 5, 18), DateTime(2026, 5, 16)},
        smokingLogDates: {DateTime(2026, 5, 17, 18)},
      );

      expect(streak, 3);
    });

    test('counts consecutive resisted cravings newest first', () {
      final streak = StreakCalculations.resistanceStreak([
        'resisted',
        'resisted',
        'still_craving',
        'resisted',
      ]);

      expect(streak, 2);
    });

    test('ignores unfinished cravings before counting resistance streak', () {
      final streak = StreakCalculations.resistanceStreak([
        'unknown',
        'resisted',
        'smoked',
      ]);

      expect(streak, 1);
    });
  });
}
