import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calculations/progress_calculations.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/providers/home_dashboard_provider.dart';
import '../../repositories/achievement_repository.dart';

final milestoneCelebrationProvider = FutureProvider<CelebrationEvent?>((
  ref,
) async {
  final dashboard = ref.watch(homeDashboardProvider).value;
  if (dashboard == null) {
    return null;
  }

  final healthKeys = ProgressCalculations.unlockedHealthMilestoneKeys(
    dashboard.smokeFreeDuration,
  );
  final achievementKeys = ProgressCalculations.unlockedAchievementKeys(
    dashboard.smokeFreeDuration,
  );
  final newlyUnlocked = await ref
      .watch(achievementRepositoryProvider)
      .unlockAll({...healthKeys, ...achievementKeys});
  if (newlyUnlocked.isEmpty) {
    return null;
  }

  final events = <CelebrationEvent>[
    ...ProgressCalculations.healthMilestones
        .where(
          (milestone) => newlyUnlocked.contains(
            ProgressCalculations.healthMilestoneAchievementKey(milestone.key),
          ),
        )
        .map(CelebrationEvent.healthMilestone),
    ...ProgressCalculations.achievements
        .where((achievement) => newlyUnlocked.contains(achievement.key))
        .map(CelebrationEvent.timeAchievement),
  ];
  if (events.isEmpty) {
    return null;
  }

  events.sort((a, b) => b.duration.compareTo(a.duration));
  return events.first;
});

enum CelebrationKind { healthMilestone, timeAchievement }

class CelebrationEvent {
  const CelebrationEvent({
    required this.kind,
    required this.key,
    required this.title,
    required this.body,
    required this.duration,
    required this.icon,
    required this.color,
  });

  factory CelebrationEvent.healthMilestone(ProgressMilestone milestone) {
    return CelebrationEvent(
      kind: CelebrationKind.healthMilestone,
      key: ProgressCalculations.healthMilestoneAchievementKey(milestone.key),
      title: '${milestone.title} smoke-free',
      body: milestone.body,
      duration: milestone.duration,
      icon: Icons.emoji_events_rounded,
      color: AppColors.accentMoney,
    );
  }

  factory CelebrationEvent.timeAchievement(ProgressMilestone achievement) {
    return CelebrationEvent(
      kind: CelebrationKind.timeAchievement,
      key: achievement.key,
      title: '${achievement.title} smoke-free',
      body: 'You protected the pause long enough to reach a new marker.',
      duration: achievement.duration,
      icon: Icons.military_tech_rounded,
      color: AppColors.primary,
    );
  }

  final CelebrationKind kind;
  final String key;
  final String title;
  final String body;
  final Duration duration;
  final IconData icon;
  final Color color;
}
