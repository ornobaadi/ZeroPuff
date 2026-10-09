import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/perspective_calculations.dart';
import 'package:zeropuff/core/calculations/progress_calculations.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/features/progress/providers/milestone_providers.dart';
import 'package:zeropuff/features/stats/screens/milestone_details_screen.dart';

void main() {
  group('Perspective', () {
    test('turns cigarettes into time at a readable scale', () {
      expect(PerspectiveCalculations.timeNotSmoking(5), '30 min');
      expect(PerspectiveCalculations.timeNotSmoking(72), '7 h');
      expect(PerspectiveCalculations.timeNotSmoking(1000), '4 days');
    });

    test('has nothing to say before anything is avoided', () {
      final facts = PerspectiveCalculations.facts(
        cigarettesAvoided: 0,
        packSize: 20,
        cravingsBeaten: 0,
      );

      expect(facts, isEmpty);
    });

    test('pictures the totals as length, time, packs and cravings', () {
      final facts = PerspectiveCalculations.facts(
        cigarettesAvoided: 130,
        packSize: 20,
        cravingsBeaten: 12,
      );

      expect(facts.length, 4);
      // 130 cigarettes at 8.4 cm.
      expect(facts[0], contains('11 m'));
      expect(facts[1], contains('13 h'));
      expect(facts[2], startsWith('6.5 packs'));
      expect(facts[3], startsWith('12 cravings'));
    });

    test('leaves packs out until a whole one is avoided', () {
      final facts = PerspectiveCalculations.facts(
        cigarettesAvoided: 8,
        packSize: 20,
        cravingsBeaten: 0,
      );

      expect(facts.any((fact) => fact.contains('pack')), isFalse);
    });
  });

  testWidgets('one screen holds the journey and the earned badges', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWithValue(
            const AsyncData(
              HomeDashboardData(
                smokeFreeDuration: Duration(days: 5),
                cigarettesAvoided: 72,
                moneySaved: 43.2,
                currencySymbol: r'$',
                cigarettesPerDay: 15,
                packPrice: 12,
                packSize: 20,
                smokeFreeDays: 5,
                smokeFreeStreakDays: 5,
                checkInStreakDays: 2,
                honestyStreakDays: 2,
                resistanceStreak: 0,
              ),
            ),
          ),
          milestoneStatsProvider.overrideWithValue(
            const MilestoneStats(
              smokeFreeDuration: Duration(days: 5),
              cravingsBeaten: 7,
              cigarettesAvoided: 72,
              packsAvoided: 3.6,
            ),
          ),
          unlockedMilestonesProvider.overrideWith(
            (ref) async => {'24_hours': DateTime(2026, 10, 2)},
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MilestoneDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Five days in: a week is next, two days off.
    expect(find.text('Next up'), findsOneWidget);
    expect(find.text('in 2 days'), findsWidgets);

    expect(find.text('Your journey'), findsOneWidget);
    expect(find.text('Reached Oct 2'), findsOneWidget);
    // Only the next two are shown until asked for.
    expect(find.text('2 weeks'), findsOneWidget);
    expect(find.text('1 month'), findsNothing);
    await tester.tap(find.textContaining('more further ahead'));
    await tester.pumpAndSettle();
    expect(find.text('1 month'), findsOneWidget);

    expect(find.text('Earned'), findsWidgets);
    expect(find.text('Craving Scout'), findsOneWidget);
    expect(find.text('7 of 10'), findsOneWidget);
    expect(find.text('First Pack Kept'), findsOneWidget);
  });
}
