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

    test('formats smoke-free duration labels', () {
      expect(ProgressCalculations.durationLabel(Duration.zero), '0 min');
      expect(
        ProgressCalculations.durationLabel(const Duration(minutes: 40)),
        '40 min',
      );
      expect(
        ProgressCalculations.durationLabel(const Duration(minutes: 60)),
        '1h',
      );
      expect(
        ProgressCalculations.durationLabel(const Duration(minutes: 400)),
        '6h 40m',
      );
      expect(
        ProgressCalculations.durationLabel(const Duration(days: 1)),
        '1 day',
      );
      expect(
        ProgressCalculations.durationLabel(const Duration(days: 30)),
        '1 month',
      );
    });

    test('returns the next time milestone', () {
      final milestone = ProgressCalculations.nextMilestone(
        const Duration(hours: 1),
      );

      expect(milestone?.key, '8_hours');
    });

    test('has no next milestone past the last one', () {
      expect(
        ProgressCalculations.nextMilestone(const Duration(days: 365 * 11)),
        isNull,
      );
    });

    test('says how far off something is', () {
      expect(
        ProgressCalculations.untilLabel(const Duration(days: 2, hours: 4)),
        'in 2 days',
      );
      expect(
        ProgressCalculations.untilLabel(const Duration(hours: 5)),
        'in 5 h',
      );
      expect(
        ProgressCalculations.untilLabel(const Duration(seconds: 20)),
        'in 1 min',
      );
    });
  });

  group('Milestones', () {
    test('every key is unique, since keys are what is stored', () {
      final keys = ProgressCalculations.milestones.map((m) => m.key).toList();

      expect(keys.toSet().length, keys.length);
    });

    test('time milestones unlock with time smoke-free', () {
      final unlocked = ProgressCalculations.unlockedKeys(
        const MilestoneStats(smokeFreeDuration: Duration(hours: 24)),
      );

      expect(unlocked, containsAll(['20_minutes', '8_hours', '24_hours']));
      expect(unlocked.contains('48_hours'), isFalse);
    });

    test('earned milestones unlock from what was done, not from waiting', () {
      const waited = MilestoneStats(smokeFreeDuration: Duration(days: 400));
      expect(
        ProgressCalculations.unlockedKeys(waited).contains('10_cravings'),
        isFalse,
      );

      const worked = MilestoneStats(
        smokeFreeDuration: Duration(minutes: 5),
        cravingsBeaten: 10,
        cigarettesAvoided: 100,
        packsAvoided: 5,
        sealedDays: 7,
        comeback: true,
      );
      final unlocked = ProgressCalculations.unlockedKeys(worked);

      expect(
        unlocked,
        containsAll([
          'first_craving',
          '10_cravings',
          '100_avoided',
          '1_pack',
          '7_sealed',
          'comeback',
        ]),
      );
      expect(unlocked.contains('25_cravings'), isFalse);
      expect(unlocked.contains('10_packs'), isFalse);
      expect(unlocked.contains('20_minutes'), isFalse);
    });

    test('reports progress towards a locked milestone', () {
      final scout = ProgressCalculations.byKey('10_cravings')!;
      const stats = MilestoneStats(
        smokeFreeDuration: Duration(days: 5),
        cravingsBeaten: 7,
      );

      expect(scout.kind, MilestoneKind.earned);
      expect(scout.progress(stats), closeTo(0.7, 0.001));
      expect(scout.progressLabel(stats), '7 of 10');

      final week = ProgressCalculations.byKey('1_week')!;
      expect(week.kind, MilestoneKind.time);
      expect(week.progressLabel(stats), 'in 2 days');
    });

    test('keys saved by earlier versions count as the same milestones', () {
      final known = ProgressCalculations.normalizeStoredKeys([
        'health_milestone_2_weeks',
        '1_week',
      ]);

      expect(known, {'2_weeks', '1_week'});
    });
  });
}
