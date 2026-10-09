import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/checkin/screens/seal_day_screen.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/models/craving_rescue_data.dart';
import 'package:zeropuff/repositories/daily_checkin_repository.dart';
import 'package:zeropuff/repositories/smoking_log_repository.dart';
import 'package:zeropuff/repositories/smoking_window_repository.dart';

/// Keeps the seal in memory, fresh for each test.
class _FakeCheckIns implements DailyCheckInRepository {
  DailyCheckInRecord? today;

  @override
  Future<DailyCheckInRecord?> getToday() async => today;

  @override
  Future<List<DailyCheckInRecord>> getRecent({int limit = 14}) async {
    return [?today];
  }

  @override
  Future<DailyCheckInRecord> saveToday({
    required bool smokeFreeToday,
    required int cigarettesSmoked,
    int? mood,
    List<String> tags = const [],
    String? note,
  }) async {
    return today = DailyCheckInRecord(
      checkInId: 'today',
      localDate: localDateKey(DateTime.now()),
      smokeFreeToday: smokeFreeToday,
      cigarettesSmoked: cigarettesSmoked,
      mood: mood,
      tags: tags,
      note: note,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  Future<_FakeCheckIns> pumpSeal(
    WidgetTester tester, {
    List<CravingRescueData> cravings = const [],
    List<SmokingLogRecord> logs = const [],
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final checkIns = _FakeCheckIns();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyCheckInRepositoryProvider.overrideWithValue(checkIns),
          homeDashboardProvider.overrideWithValue(const AsyncLoading()),
          recentCravingsProvider.overrideWith((ref) async => cravings),
          recentSmokingLogsProvider.overrideWith((ref) async => logs),
          ritualsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SealDayScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return checkIns;
  }

  testWidgets('one tap seals a smoke-free day, then asks what made it easier', (
    tester,
  ) async {
    final checkIns = await pumpSeal(tester);

    expect(find.text('Today, so far'), findsOneWidget);
    expect(find.text('No cigarettes logged'), findsOneWidget);

    await tester.tap(find.text('Smoke-free today'));
    await tester.pumpAndSettle();

    expect(find.text('Today is sealed'), findsOneWidget);
    expect(checkIns.today?.smokeFreeToday, isTrue);
    expect(find.text('What made today easier?'), findsOneWidget);

    await tester.tap(find.text('Slept well'));
    await tester.pumpAndSettle();
    expect(checkIns.today?.tags, ['slept_well']);
  });

  testWidgets('asks what helped when cravings were beaten today', (
    tester,
  ) async {
    await pumpSeal(
      tester,
      cravings: [
        CravingRescueData(
          sessionId: 'a',
          startedAt: DateTime.now(),
          intensity: 6,
          triggers: const [],
          outcome: 'resisted',
        ),
      ],
    );

    expect(find.text('1 craving beaten'), findsOneWidget);
    await tester.tap(find.text('Smoke-free today'));
    await tester.pumpAndSettle();

    expect(find.text('What helped you through?'), findsOneWidget);
  });

  testWidgets('a day with cigarettes is closed, not sealed smoke-free', (
    tester,
  ) async {
    final checkIns = await pumpSeal(
      tester,
      logs: [
        SmokingLogRecord(
          logId: 'log',
          count: 2,
          trigger: 'stress',
          smokedAt: DateTime.now(),
        ),
      ],
    );

    expect(find.text('2 cigarettes logged'), findsOneWidget);
    expect(find.text('I slipped today'), findsNothing);

    await tester.tap(find.text('Close the day'));
    await tester.pumpAndSettle();

    expect(find.text('Today is closed'), findsOneWidget);
    expect(checkIns.today?.smokeFreeToday, isFalse);
    expect(checkIns.today?.cigarettesSmoked, 2);
    expect(find.text('What made it hard?'), findsOneWidget);
  });
}
