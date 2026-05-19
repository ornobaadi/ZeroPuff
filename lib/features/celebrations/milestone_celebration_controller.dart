import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calculations/progress_calculations.dart';
import '../../features/home/providers/home_dashboard_provider.dart';
import '../../repositories/achievement_repository.dart';

final milestoneCelebrationProvider = FutureProvider<ProgressMilestone?>((
  ref,
) async {
  final dashboard = ref.watch(homeDashboardProvider).value;
  if (dashboard == null) {
    return null;
  }

  final unlockedKeys = ProgressCalculations.unlockedHealthMilestoneKeys(
    dashboard.smokeFreeDuration,
  );
  if (unlockedKeys.isEmpty) {
    return null;
  }

  final newlyUnlocked = await ref
      .watch(achievementRepositoryProvider)
      .unlockAll(unlockedKeys);
  if (newlyUnlocked.isEmpty) {
    return null;
  }

  final milestoneKeys = newlyUnlocked
      .map(ProgressCalculations.healthMilestoneKeyFromAchievement)
      .toSet();
  final unlockedMilestones = ProgressCalculations.healthMilestones
      .where((milestone) => milestoneKeys.contains(milestone.key))
      .toList();
  if (unlockedMilestones.isEmpty) {
    return null;
  }

  unlockedMilestones.sort((a, b) => b.duration.compareTo(a.duration));
  return unlockedMilestones.first;
});
