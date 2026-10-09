import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/journal_insights.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/features/journal/screens/quit_journal_screen.dart';
import 'package:zeropuff/models/craving_rescue_data.dart';
import 'package:zeropuff/models/onboarding_data.dart';
import 'package:zeropuff/repositories/daily_checkin_repository.dart';
import 'package:zeropuff/repositories/smoking_log_repository.dart';

void main() {
  final october = DateTime(2026, 10);

  CravingRescueData craving(
    DateTime at, {
    List<String> triggers = const [],
    String outcome = 'resisted',
  }) {
    return CravingRescueData(
      sessionId: at.toIso8601String(),
      startedAt: at,
      intensity: 6,
      triggers: triggers,
      outcome: outcome,
    );
  }

  DailyCheckInRecord seal(DateTime day, List<String> tags) {
    return DailyCheckInRecord(
      checkInId: day.toIso8601String(),
      localDate: localDateKey(day),
      smokeFreeToday: true,
      cigarettesSmoked: 0,
      tags: tags,
      createdAt: day,
    );
  }

  group('Month insights', () {
    test('names the hardest weekday and time of day', () {
      final insights = MonthInsights.forMonth(
        month: october,
        // The 2nd and 9th are Fridays; the 7th is a Wednesday.
        cravings: [
          craving(DateTime(2026, 10, 2, 19), triggers: ['stress']),
          craving(DateTime(2026, 10, 9, 20), triggers: ['stress']),
          craving(DateTime(2026, 10, 9, 18, 30), triggers: ['coffee']),
          craving(DateTime(2026, 10, 7, 9)),
          craving(DateTime(2026, 9, 20, 9)),
        ],
        checkIns: const [],
        helpfulTags: const {},
      );

      expect(insights.cravings, 4);
      expect(insights.cravingsLastMonth, 1);
      expect(insights.hardestWeekday, DateTime.friday);
      expect(insights.hardestPartOfDay, PartOfDay.evening);
      expect(insights.topTrigger, 'stress');
      // Sunday first.
      expect(insights.byWeekday, [0, 0, 0, 1, 0, 3, 0]);
    });

    test('does not name a pattern from too few cravings', () {
      final insights = MonthInsights.forMonth(
        month: october,
        cravings: [
          craving(DateTime(2026, 10, 2, 19)),
          craving(DateTime(2026, 10, 9, 20)),
        ],
        checkIns: const [],
        helpfulTags: const {},
      );

      expect(insights.hardestWeekday, isNull);
      expect(insights.hardestPartOfDay, isNull);
    });

    test('does not name a hardest day when two tie', () {
      final insights = MonthInsights.forMonth(
        month: october,
        cravings: [
          craving(DateTime(2026, 10, 2, 9)),
          craving(DateTime(2026, 10, 9, 14)),
          craving(DateTime(2026, 10, 7, 19)),
          craving(DateTime(2026, 10, 14, 23)),
        ],
        checkIns: const [],
        helpfulTags: const {},
      );

      expect(insights.hardestWeekday, isNull);
    });

    test('finds what helped most, ignoring what made days hard', () {
      final insights = MonthInsights.forMonth(
        month: october,
        cravings: const [],
        checkIns: [
          seal(DateTime(2026, 10, 3), ['kept_busy', 'water']),
          seal(DateTime(2026, 10, 4), ['kept_busy']),
          seal(DateTime(2026, 10, 5), ['stress', 'stress']),
          seal(DateTime(2026, 9, 5), ['water', 'water', 'water']),
        ],
        helpfulTags: const {'kept_busy', 'water'},
      );

      expect(insights.hasCravings, isFalse);
      expect(insights.topHelpfulTag, 'kept_busy');
    });
  });

  testWidgets('the journal fills in days since quitting and tells the day', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final now = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBaselineProvider.overrideWith(
            (ref) async => OnboardingData(
              quitDate: now.subtract(const Duration(days: 40)),
              cigarettesPerDay: 10,
              packPrice: 200,
              packSize: 20,
              completed: true,
            ),
          ),
          latestSmokeAtProvider.overrideWith((ref) async => null),
          todayCheckInProvider.overrideWith((ref) async => null),
          recentCheckInsProvider.overrideWith((ref) async => []),
          recentSmokingLogsProvider.overrideWith(
            (ref) async => <SmokingLogRecord>[],
          ),
          recentCravingsProvider.overrideWith(
            (ref) async => [craving(now)],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const QuitJournalScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Today is selected: smoke-free so far, with the craving beaten.
    expect(find.textContaining('Smoke-free so far.'), findsOneWidget);
    expect(find.textContaining('1 craving beaten.'), findsOneWidget);
    expect(find.text('Craving beaten'), findsOneWidget);
    expect(find.text('Seal today'), findsOneWidget);

    // The lens switch changes what the cells show.
    await tester.tap(find.text('Cravings'));
    await tester.pumpAndSettle();
    expect(
      find.text('The number is how many cravings were logged.'),
      findsOneWidget,
    );
  });
}
