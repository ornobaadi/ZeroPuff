import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/progress_calculations.dart';

void main() {
  group('ProgressCalculations', () {
    test('calculates cigarettes avoided from duration and baseline', () {
      expect(
        ProgressCalculations.cigarettesAvoided(
          smokeFreeDuration: const Duration(hours: 12),
          cigarettesPerDay: 20,
        ),
        10,
      );
    });

    test('calculates saved money from avoided cigarettes', () {
      expect(
        ProgressCalculations.moneySaved(
          cigarettesAvoided: 10,
          packPrice: 12,
          packSize: 20,
        ),
        6,
      );
    });

    test('returns the next milestone', () {
      final milestone = ProgressCalculations.nextMilestone(
        const Duration(hours: 1),
      );

      expect(milestone?.key, '8_hours');
    });

    test('clamps milestone progress', () {
      final milestone = ProgressCalculations.healthMilestones.first;

      expect(
        ProgressCalculations.milestoneProgress(
          smokeFreeDuration: const Duration(hours: 1),
          milestone: milestone,
        ),
        1,
      );
    });

    test('unlocks achievements by elapsed duration', () {
      final unlocked = ProgressCalculations.unlockedAchievementKeys(
        const Duration(hours: 12),
      );

      expect(unlocked.contains('1_hour'), isTrue);
      expect(unlocked.contains('6_hours'), isTrue);
      expect(unlocked.contains('12_hours'), isTrue);
      expect(unlocked.contains('1_day'), isFalse);
    });
  });
}
