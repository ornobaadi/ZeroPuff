import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../repositories/achievement_repository.dart';

final unlockedAchievementsProvider = FutureProvider<Set<String>>((ref) async {
  final data = ref.watch(homeDashboardProvider).value;
  if (data == null) {
    return const {};
  }
  final computed = ProgressCalculations.unlockedAchievementKeys(
    data.smokeFreeDuration,
  );
  final repository = ref.watch(achievementRepositoryProvider);
  final stored = await repository.unlockedKeys();
  return {...stored, ...computed};
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboard = ref.watch(homeDashboardProvider);
    final recentCheckIns = ref.watch(recentCheckInsProvider);
    final recentCravings = ref.watch(recentCravingsProvider);
    final unlockedAchievements = ref.watch(unlockedAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: dashboard.when(
            data: (data) {
              final next = ProgressCalculations.nextMilestone(
                data.smokeFreeDuration,
              );
              final recent = recentCheckIns.value ?? const [];
              final cravings = recentCravings.value ?? const [];
              final unlocked = unlockedAchievements.value ?? const {};
              final smokeFreeCheckIns = recent
                  .where((record) => record.smokeFreeToday)
                  .length;

              return [
                Text(
                  'Your recovery map',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A quiet view of what is changing, without turning this into a game.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressStat(
                        label: 'Smoke-free',
                        value: '${data.smokeFreeDays}d',
                        icon: Icons.air_rounded,
                        color: AppColors.primary,
                        onTap: () => context.push(AppRoutes.smokeFreeDetails),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ProgressStat(
                        label: 'Saved',
                        value:
                            '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
                        icon: Icons.savings_rounded,
                        color: AppColors.accentMoney,
                        onTap: () => context.push(AppRoutes.savingsDetails),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressStat(
                        label: 'Avoided',
                        value: '${data.cigarettesAvoided}',
                        icon: Icons.smoke_free_rounded,
                        color: AppColors.accentStreak,
                        onTap: () => context.push(AppRoutes.avoidedDetails),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ProgressStat(
                        label: 'Check-ins',
                        value: '${recent.length}',
                        icon: Icons.fact_check_rounded,
                        color: AppColors.accentCraving,
                        onTap: () => context.push(AppRoutes.checkInDetails),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _CravingAnalysisCard(
                  cravingCount: cravings.length,
                  onTap: () => context.push(AppRoutes.cravingAnalysis),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                if (next != null)
                  _NextMilestoneCard(
                    next: next,
                    data: data,
                    onTap: () => context.push(AppRoutes.healthDetails),
                  ),
                if (next != null) const SizedBox(height: AppSpacing.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Health timeline',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.healthDetails),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...ProgressCalculations.healthMilestones.map(
                  (milestone) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.componentGap,
                    ),
                    child: _PreviewMilestone(
                      title: milestone.title,
                      body: milestone.body,
                      active: data.smokeFreeDuration >= milestone.duration,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Achievements',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.achievementsDetails),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ProgressCalculations.achievements.map((
                    achievement,
                  ) {
                    return _AchievementChip(
                      label: achievement.title,
                      unlocked: unlocked.contains(achievement.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _CheckInSummary(
                  total: recent.length,
                  smokeFree: smokeFreeCheckIns,
                ),
              ];
            },
            loading: () => [
              const SizedBox(height: 160),
              const Center(child: CircularProgressIndicator()),
            ],
            error: (error, _) => [
              Text('Progress unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
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

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.accentCraving.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.accentCraving.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentCraving.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.accentCraving,
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
                    cravingCount < 3
                        ? '$cravingCount logged. Three unlocks useful patterns.'
                        : '$cravingCount logs ready for pattern spotting.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _NextMilestoneCard extends StatelessWidget {
  const _NextMilestoneCard({
    required this.next,
    required this.data,
    required this.onTap,
  });

  final ProgressMilestone next;
  final HomeDashboardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = next.duration - data.smokeFreeDuration;
    final progress = ProgressCalculations.milestoneProgress(
      smokeFreeDuration: data.smokeFreeDuration,
      milestone: next,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.accentMoney.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.accentMoney.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Next milestone',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(next.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                color: AppColors.accentMoney,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${_durationLabel(remaining)} left',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationLabel(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                if (onTap != null) const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: theme.textTheme.headlineSmall),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMilestone extends StatelessWidget {
  const _PreviewMilestone({
    required this.title,
    required this.body,
    required this.active,
  });

  final String title;
  final String body;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? AppColors.primary : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.1)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  const _AchievementChip({required this.label, required this.unlocked});

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.primary.withValues(alpha: 0.12)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.24)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
            size: 16,
            color: unlocked ? AppColors.primary : theme.colorScheme.outline,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: theme.textTheme.labelMedium),
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              total == 0
                  ? 'No check-ins yet. Start with today.'
                  : '$smokeFree of your last $total check-ins were smoke-free.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
