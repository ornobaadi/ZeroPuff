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

    test('calculates life minutes won back from avoided cigarettes', () {
      expect(ProgressCalculations.lifeMinutesWonBack(0), 0);
      expect(ProgressCalculations.lifeMinutesWonBack(1), 20);
      expect(ProgressCalculations.lifeMinutesWonBack(3), 60);
      expect(ProgressCalculations.lifeMinutesWonBack(72), 1440);
    });

    test('formats life won back labels', () {
      expect(ProgressCalculations.lifeWonBackLabel(Duration.zero), '0 min');
      expect(
        ProgressCalculations.lifeWonBackLabel(const Duration(minutes: 40)),
        '40 min',
      );
      expect(
        ProgressCalculations.lifeWonBackLabel(const Duration(minutes: 60)),
        '1h',
      );
      expect(
        ProgressCalculations.lifeWonBackLabel(const Duration(minutes: 400)),
        '6h 40m',
      );
      expect(
        ProgressCalculations.lifeWonBackLabel(const Duration(days: 1)),
        '1 day',
      );
      expect(
        ProgressCalculations.lifeWonBackLabel(const Duration(days: 30)),
        '1 month',
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
