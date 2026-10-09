import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/calculations/today_card_calculations.dart';
import '../../../repositories/daily_loop_repository.dart';
import '../../../repositories/smoking_window_repository.dart';
import 'home_dashboard_provider.dart';

/// What Home shows under the clock right now. Each input falls back to
/// "nothing known" on its own, so one failed read never hides the card.
final todayCardProvider = Provider<TodayCard?>((ref) {
  final dashboard = ref.watch(homeDashboardProvider).value;
  if (dashboard == null) {
    return null;
  }
  final now = ref.watch(homeTickerProvider).value ?? DateTime.now();
  final rituals = ref.watch(ritualsProvider).value ?? const [];
  final cravings = ref.watch(recentCravingsProvider).value ?? const [];
  final pledge = ref.watch(pledgedTodayProvider);
  final goal = ref.watch(savingsGoalProvider).value;

  final analysis = CravingAnalysisCalculations.analyze(
    cravings: cravings,
    smokingLogs: const [],
    now: now,
  );

  return TodayCardCalculations.pick(
    now: now,
    rituals: rituals,
    // Until the answer is known, do not ask for a promise already made.
    pledgedToday: pledge.value ?? true,
    sealedToday: dashboard.todaySealed,
    cravings: cravings,
    moneyPerCigarette: dashboard.packSize <= 0
        ? 0
        : dashboard.packPrice / dashboard.packSize,
    currencySymbol: dashboard.currencySymbol,
    moneySaved: dashboard.moneySaved,
    goalName: goal?.name,
    goalTarget: goal?.target,
    insights: analysis.hasEnoughData ? analysis.insights : const [],
  );
});
