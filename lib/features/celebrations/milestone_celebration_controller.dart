import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calculations/progress_calculations.dart';
import '../../features/home/providers/home_dashboard_provider.dart';
import '../../repositories/achievement_repository.dart';

final milestoneCelebrationProvider = FutureProvider<CelebrationEvent?>((
  ref,
) async {
  final dashboard = ref.watch(homeDashboardProvider).value;
  if (dashboard == null) {
    return null;
  }
  final cravings = ref.watch(recentCravingsProvider).value ?? const [];

  final milestoneKeys = ProgressCalculations.unlockedMilestoneKeys(
    dashboard.smokeFreeDuration,
  );
  final achievementKeys = ProgressCalculations.unlockedAchievementKeysForStats(
    smokeFreeDuration: dashboard.smokeFreeDuration,
    cravingCount: cravings.length,
    cigarettesAvoided: dashboard.cigarettesAvoided,
    moneySaved: dashboard.moneySaved,
  );
  final newlyUnlocked = await ref
      .watch(achievementRepositoryProvider)
      .unlockAll({...milestoneKeys, ...achievementKeys});
  if (newlyUnlocked.isEmpty) {
    return null;
  }

  final events = <CelebrationEvent>[
    ...ProgressCalculations.streakMilestones
        .where(
          (milestone) => newlyUnlocked.contains(
            ProgressCalculations.milestoneAchievementKey(milestone.key),
          ),
        )
        .map(CelebrationEvent.milestone),
    ...ProgressCalculations.achievements
        .where((achievement) => newlyUnlocked.contains(achievement.key))
        .map(CelebrationEvent.achievement),
  ];
  if (events.isEmpty) {
    return null;
  }

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
      key: ProgressCalculations.milestoneAchievementKey(milestone.key),
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
