import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../repositories/achievement_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../widgets/badge_image.dart';

final unlockedAchievementsProvider = FutureProvider<Set<String>>((ref) async {
  final data = ref.watch(homeDashboardProvider).value;
  if (data == null) {
    return const {};
  }
  final cravings = ref.watch(recentCravingsProvider).value ?? const [];
  final computed = ProgressCalculations.unlockedAchievementKeysForStats(
    smokeFreeDuration: data.smokeFreeDuration,
    cravingCount: cravings.length,
    cigarettesAvoided: data.cigarettesAvoided,
    moneySaved: data.moneySaved,
  );
  final repository = ref.watch(achievementRepositoryProvider);
  final stored = await repository.unlockedKeys();
  return {...stored, ...computed};
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);

    void openDetail(String route) {
      HapticService.selection(enabled: hapticsEnabled);
      context.push(route);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: dashboard.when(
          loading: () => const StateView.loading(label: 'Loading progress'),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(homeDashboardProvider),
          ),
          data: (data) => _ProgressContent(data: data, onOpen: openDetail),
        ),
      ),
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({required this.data, required this.onOpen});

  final HomeDashboardData data;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recent = ref.watch(recentCheckInsProvider).value ?? const [];
    final cravings = ref.watch(recentCravingsProvider).value ?? const [];
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const {};
    final smokeFreeCheckIns = recent
        .where((record) => record.smokeFreeToday)
        .length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'See the milestones you have reached and what comes next.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MilestonesCard(
                smokeFreeDuration: data.smokeFreeDuration,
                onTap: () => onOpen(AppRoutes.milestoneDetails),
              ),
              const SizedBox(height: AppSpacing.md),
              _AchievementsCard(
                achievements: ProgressCalculations.achievements,
                unlocked: unlocked,
                onTap: () => onOpen(AppRoutes.achievementsDetails),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(title: 'Quick stats'),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                left: StatCard(
                  label: 'Smoke-free days',
                  value: '${data.smokeFreeDays}',
                  icon: Icons.air_rounded,
                  onTap: () => onOpen(AppRoutes.smokeFreeDetails),
                ),
                right: StatCard(
                  label: 'Money won back',
                  value:
                      '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
                  icon: Icons.savings_rounded,
                  tone: StatTone.money,
                  onTap: () => onOpen(AppRoutes.savingsDetails),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                left: StatCard(
                  label: 'Not smoked',
                  value: '${data.cigarettesAvoided}',
                  icon: Icons.smoke_free_rounded,
                  tone: StatTone.streak,
                  onTap: () => onOpen(AppRoutes.avoidedDetails),
                ),
                right: StatCard(
                  label: 'Check-ins',
                  value: '${recent.length}',
                  icon: Icons.fact_check_rounded,
                  tone: StatTone.craving,
                  onTap: () => onOpen(AppRoutes.checkInDetails),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                left: StatCard(
                  label: 'Time smoke-free',
                  value: ProgressCalculations.durationLabel(
                    data.smokeFreeDuration,
                  ),
                  icon: Icons.timer_rounded,
                  onTap: () => onOpen(AppRoutes.milestoneDetails),
                ),
                right: StatCard(
                  label: 'Milestones',
                  value:
                      '${ProgressCalculations.unlockedMilestoneKeys(data.smokeFreeDuration).length}',
                  icon: Icons.flag_rounded,
                  tone: StatTone.streak,
                  onTap: () => onOpen(AppRoutes.milestoneDetails),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _CravingAnalysisCard(
                cravingCount: cravings.length,
                onTap: () => onOpen(AppRoutes.cravingAnalysis),
              ),
              const SizedBox(height: AppSpacing.md),
              _CheckInSummary(total: recent.length, smokeFree: smokeFreeCheckIns),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.smokeFreeDuration, required this.onTap});

  final Duration smokeFreeDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = ProgressCalculations.currentMilestone(smokeFreeDuration);
    final next = ProgressCalculations.nextMilestone(smokeFreeDuration);
    final hasReachedFirst =
        smokeFreeDuration >=
        ProgressCalculations.streakMilestones.first.duration;
    final shown = next ?? current;
    final previous = ProgressCalculations.previousMilestone(shown);
    final previousDuration = previous?.duration ?? Duration.zero;
    final segmentSeconds = (shown.duration - previousDuration).inSeconds;
    final elapsedSeconds = (smokeFreeDuration - previousDuration).inSeconds;
    final progress = next == null || segmentSeconds <= 0
        ? 1.0
        : (elapsedSeconds / segmentSeconds).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    final headline = hasReachedFirst
        ? 'Current milestone: ${current.title}'
        : 'First milestone: 20 minutes';
    final progressText = next == null
        ? 'All milestones reached'
        : '$percent% to ${next.title}';

    return AppCard(
      style: AppCardStyle.tonal,
      onTap: onTap,
      semanticLabel: 'Milestones. $headline. $progressText. Double tap for details.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BadgeImage(
                asset: current.badgeAsset ?? shown.badgeAsset,
                unlocked: hasReachedFirst,
                size: 72,
                fallbackIcon: Icons.flag_rounded,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      headline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasReachedFirst
                ? current.body
                : 'Your first milestone arrives at 20 smoke-free minutes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            progressText,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            year2023: false, // ignore: deprecated_member_use
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: scheme.surface.withValues(alpha: 0.5),
            semanticsLabel: 'Progress to next milestone',
            semanticsValue: '$percent percent',
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({
    required this.achievements,
    required this.unlocked,
    required this.onTap,
  });

  final List<ProgressMilestone> achievements;
  final Set<String> unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final unlockedCount = achievements
        .where((achievement) => unlocked.contains(achievement.key))
        .length;
    final nextLocked = achievements
        .where((achievement) => !unlocked.contains(achievement.key))
        .firstOrNull;
    final progress = achievements.isEmpty
        ? 0.0
        : unlockedCount / achievements.length;
    final subtitle = nextLocked == null
        ? 'Every badge is unlocked.'
        : 'Next badge: ${nextLocked.title}';

    return AppCard(
      onTap: onTap,
      semanticLabel:
          'Achievements. $unlockedCount of ${achievements.length} unlocked. $subtitle. Double tap for details.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accents.moneyContainer,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.componentGap),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: accents.onMoneyContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achievements', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$unlockedCount/${achievements.length} unlocked',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            year2023: false, // ignore: deprecated_member_use
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: accents.money,
            backgroundColor: scheme.surfaceContainerHighest,
            semanticsLabel: 'Achievements unlocked',
            semanticsValue: '$unlockedCount of ${achievements.length}',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.componentGap),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return BadgeImage(
                  asset: achievement.badgeAsset,
                  unlocked: unlocked.contains(achievement.key),
                  size: 96,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CravingAnalysisCard extends StatelessWidget {
  const _CravingAnalysisCard({required this.cravingCount, required this.onTap});

  final int cravingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final subtitle = cravingCount < 3
        ? '$cravingCount logged. Three unlock useful patterns.'
        : '$cravingCount logs ready for pattern spotting.';

    return AppCard(
      onTap: onTap,
      semanticLabel: 'Craving analysis. $subtitle Double tap for details.',
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accents.cravingContainer,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.componentGap),
              child: Icon(
                Icons.insights_rounded,
                color: accents.onCravingContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Craving analysis', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _CheckInSummary extends StatelessWidget {
  const _CheckInSummary({required this.total, required this.smokeFree});

  final int total;
  final int smokeFree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      style: AppCardStyle.outlined,
      child: Row(
        children: [
          Icon(Icons.fact_check_rounded, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              total == 0
                  ? 'No check-ins yet. Start with today.'
                  : '$smokeFree of your last $total check-ins were smoke-free.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
