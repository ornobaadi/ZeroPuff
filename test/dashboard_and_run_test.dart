import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/run_calculations.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/models/onboarding_data.dart';
import 'package:zeropuff/repositories/daily_checkin_repository.dart';
import 'package:zeropuff/repositories/smoking_log_repository.dart';

void main() {
  group('Dashboard', () {
    Future<HomeDashboardData> dashboard({
      required DateTime quitDate,
      List<SmokingLogRecord> logs = const [],
      List<DailyCheckInRecord> checkIns = const [],
    }) async {
      final latest = logs.isEmpty
          ? null
          : logs
                .map((log) => log.smokedAt)
                .reduce((a, b) => a.isAfter(b) ? a : b);
      final container = ProviderContainer(
        overrides: [
          homeBaselineProvider.overrideWith(
            (ref) async => OnboardingData(
              quitDate: quitDate,
              cigarettesPerDay: 10,
              packPrice: 200,
              packSize: 20,
              completed: true,
            ),
          ),
          latestSmokeAtProvider.overrideWith((ref) async => latest),
          todayCheckInProvider.overrideWith((ref) async => null),
          recentCheckInsProvider.overrideWith((ref) async => checkIns),
          recentSmokingLogsProvider.overrideWith((ref) async => logs),
          recentCravingsProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);
      await container.read(homeBaselineProvider.future);
      await container.read(latestSmokeAtProvider.future);
      await container.read(todayCheckInProvider.future);
      await container.read(recentCheckInsProvider.future);
      await container.read(recentSmokingLogsProvider.future);
      await container.read(recentCravingsProvider.future);
      return container.read(homeDashboardProvider).value!;
    }

    test('a slip costs the cigarettes smoked, not everything kept', () async {
      final now = DateTime.now();
      final data = await dashboard(
        quitDate: now.subtract(const Duration(days: 10, minutes: 5)),
        logs: [
          SmokingLogRecord(
            logId: 'slip',
            count: 2,
            trigger: 'stress',
            smokedAt: now.subtract(const Duration(days: 3)),
          ),
        ],
      );

      // Ten days at ten a day, less the two smoked.
      expect(data.cigarettesAvoided, 98);
      expect(data.moneySaved, closeTo(980, 0.01));
      // The clock still restarts from the cigarette.
      expect(data.smokeFreeDuration.inDays, 3);
    });

    test('with no slips it is simply the days since quitting', () async {
      final now = DateTime.now();
      final data = await dashboard(
        quitDate: now.subtract(const Duration(days: 4, minutes: 5)),
      );

      expect(data.cigarettesAvoided, 40);
      expect(data.smokeFreeStreakDays, greaterThanOrEqualTo(3));
      expect(data.todaySealed, isFalse);
    });

    test('a day sealed as slipped is not counted twice with its log', () async {
      final now = DateTime.now();
      final slipAt = now.subtract(const Duration(days: 2));
      final data = await dashboard(
        quitDate: now.subtract(const Duration(days: 10, minutes: 5)),
        logs: [
          SmokingLogRecord(
            logId: 'slip',
            count: 3,
            trigger: 'stress',
            smokedAt: slipAt,
          ),
        ],
        checkIns: [
          DailyCheckInRecord(
            checkInId: 'seal',
            localDate: localDateKey(slipAt),
            smokeFreeToday: false,
            cigarettesSmoked: 3,
            createdAt: slipAt,
          ),
        ],
      );

      expect(data.cigarettesAvoided, 97);
    });
  });

  group('Run targets', () {
    test('names the next length to aim at', () {
      expect(RunCalculations.nextTarget(0)?.days, 1);
      expect(RunCalculations.nextTarget(7)?.label, '2-week');
      expect(RunCalculations.nextTarget(400), isNull);
    });
  });

  group('Run end insight', () {
    test('needs runs to have ended at least twice', () {
      final insight = RunCalculations.runEndInsight(
        runEnds: [DateTime(2026, 10, 2)],
        slipTimes: [DateTime(2026, 10, 2, 21)],
      );

      expect(insight, isNull);
    });

    test('names the weekday and time of day that repeat', () {
      // Both are Fridays.
      final insight = RunCalculations.runEndInsight(
        runEnds: [DateTime(2026, 10, 2), DateTime(2026, 10, 9)],
        slipTimes: [
          DateTime(2026, 10, 2, 19, 30),
          DateTime(2026, 10, 9, 20, 10),
        ],
      );

      expect(
        insight,
        'Your runs have ended most often on Fridays, usually in the evening.',
      );
    });

    test('says nothing when nothing repeats', () {
      // A Friday morning and a Monday night.
      final insight = RunCalculations.runEndInsight(
        runEnds: [DateTime(2026, 10, 2), DateTime(2026, 10, 5)],
        slipTimes: [DateTime(2026, 10, 2, 9), DateTime(2026, 10, 5, 23)],
      );

      expect(insight, isNull);
    });
  });

  group('Savings targets', () {
    test('are counted in packs, so they fit any currency', () {
      final next = SavingsTargets.next(saved: 1200, packPrice: 340);

      expect(next?.packs, 5);
      expect(next?.amount, 1700);
    });

    test('have nothing to offer without a pack price', () {
      expect(SavingsTargets.next(saved: 10, packPrice: 0), isNull);
    });
  });
}
