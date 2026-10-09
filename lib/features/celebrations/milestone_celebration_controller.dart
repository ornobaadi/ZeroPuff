import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calculations/progress_calculations.dart';
import '../../features/progress/providers/milestone_providers.dart';
import '../../repositories/achievement_repository.dart';

final milestoneCelebrationProvider = FutureProvider<CelebrationEvent?>((
  ref,
) async {
  final stats = ref.watch(milestoneStatsProvider);
  if (stats == null) {
    return null;
  }
  final repository = ref.watch(achievementRepositoryProvider);
  final known = ProgressCalculations.normalizeStoredKeys(
    await repository.unlockedKeys(),
  );
  final fresh = ProgressCalculations.unlockedKeys(stats).difference(known);
  if (fresh.isEmpty) {
    return null;
  }
  await repository.unlockAll(fresh);

  final events = [
    for (final key in fresh)
      if (ProgressCalculations.byKey(key) case final milestone?)
        milestone.kind == MilestoneKind.time
            ? CelebrationEvent.milestone(milestone)
            : CelebrationEvent.achievement(milestone),
  ];
  if (events.isEmpty) {
    return null;
  }

  // Several can unlock at once; celebrate the biggest.
  events.sort((a, b) => b.duration.compareTo(a.duration));
  return events.first;
});

enum CelebrationKind { milestone, timeAchievement }

class CelebrationEvent {
  const CelebrationEvent({
    required this.kind,
    required this.key,
    required this.title,
    required this.body,
    required this.duration,
    required this.icon,
    this.badgeAsset,
  });

  factory CelebrationEvent.milestone(ProgressMilestone milestone) {
    return CelebrationEvent(
      kind: CelebrationKind.milestone,
      key: milestone.key,
      title: '${milestone.title} smoke-free',
      body: milestone.body,
      duration: milestone.duration,
      icon: Symbols.emoji_events_rounded,
      badgeAsset: milestone.badgeAsset,
    );
  }

  factory CelebrationEvent.achievement(ProgressMilestone achievement) {
    return CelebrationEvent(
      kind: CelebrationKind.timeAchievement,
      key: achievement.key,
      title: achievement.title,
      body: achievement.body,
      duration: achievement.duration,
      icon: Symbols.military_tech_rounded,
      badgeAsset: achievement.badgeAsset,
    );
  }

  final CelebrationKind kind;
  final String key;
  final String title;
  final String body;
  final Duration duration;
  final IconData icon;
  final String? badgeAsset;
}
