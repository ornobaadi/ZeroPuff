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

      expect(milestone?.key, '12_hours');
    });

    test('moves past the first milestone after it is completed', () {
      final milestone = ProgressCalculations.nextMilestone(
        const Duration(minutes: 22),
      );

      expect(milestone?.key, '12_hours');
    });

    test('maps health milestone keys to synced achievement keys', () {
      final unlocked = ProgressCalculations.unlockedHealthMilestoneKeys(
        const Duration(minutes: 22),
      );

      expect(unlocked, {'health_milestone_20_minutes'});
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
        const Duration(hours: 24),
      );

      expect(unlocked.contains('20_minutes'), isTrue);
      expect(unlocked.contains('8_hours'), isTrue);
      expect(unlocked.contains('24_hours'), isTrue);
      expect(unlocked.contains('48_hours'), isFalse);
    });

    test('unlocks stat achievements from cravings, avoided, and savings', () {
      final unlocked = ProgressCalculations.unlockedAchievementKeysForStats(
        smokeFreeDuration: const Duration(days: 2),
        cravingCount: 10,
        cigarettesAvoided: 100,
        moneySaved: 50,
      );

      expect(unlocked.contains('10_cravings'), isTrue);
      expect(unlocked.contains('100_avoided'), isTrue);
      expect(unlocked.contains('50_saved'), isTrue);
    });
  });
}
