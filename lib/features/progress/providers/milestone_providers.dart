import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../repositories/achievement_repository.dart';
import '../../home/providers/home_dashboard_provider.dart';

/// What milestones are measured against, from the current state of the quit.
final milestoneStatsProvider = Provider<MilestoneStats?>((ref) {
  final data = ref.watch(homeDashboardProvider).value;
  if (data == null) {
    return null;
  }
  final cravings = ref.watch(recentCravingsProvider).value ?? const [];
  final logs = ref.watch(recentSmokingLogsProvider).value ?? const [];
  final history = ref.watch(dayHistoryProvider);

  final beaten = cravings.where((craving) => craving.resisted).toList();
  final firstSlip = logs.isEmpty
      ? null
      : logs.map((log) => log.smokedAt).reduce((a, b) => a.isBefore(b) ? a : b);

  return MilestoneStats(
    smokeFreeDuration: data.smokeFreeDuration,
    cravingsBeaten: beaten.length,
    cigarettesAvoided: data.cigarettesAvoided,
    packsAvoided: data.packSize <= 0
        ? 0
        : data.cigarettesAvoided / data.packSize,
    sealedDays: history?.sealedCount ?? 0,
    comeback:
        firstSlip != null &&
        beaten.any((craving) => craving.startedAt.isAfter(firstSlip)),
  );
});

/// Every milestone reached so far, with the day it was reached when that is
/// known. A milestone stays reached once earned, even if the clock restarts.
final unlockedMilestonesProvider = FutureProvider<Map<String, DateTime?>>((
  ref,
) async {
  final stats = ref.watch(milestoneStatsProvider);
  final stored = await ref.watch(achievementRepositoryProvider).unlockedAt();

  final unlocked = <String, DateTime?>{};
  stored.forEach((key, at) {
    final current = ProgressCalculations.normalizeStoredKeys([key]).first;
    final known = unlocked[current];
    // An older and a newer key for the same milestone: keep the earlier day.
    if (!unlocked.containsKey(current) ||
        (at != null && (known == null || at.isBefore(known)))) {
      unlocked[current] = at;
    }
  });
  if (stats != null) {
    for (final key in ProgressCalculations.unlockedKeys(stats)) {
      unlocked.putIfAbsent(key, () => null);
    }
  }
  return unlocked;
});
