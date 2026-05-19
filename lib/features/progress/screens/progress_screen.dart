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
                _AchievementShowcaseCard(
                  achievements: ProgressCalculations.achievements,
                  unlocked: unlocked,
                  onTap: () => context.push(AppRoutes.achievementsDetails),
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

class _AchievementShowcaseCard extends StatelessWidget {
  const _AchievementShowcaseCard({
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
    final unlockedCount = achievements
        .where((achievement) => unlocked.contains(achievement.key))
        .length;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Achievements', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$unlockedCount of ${achievements.length} unlocked',
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
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 178,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _AchievementBadgePreview(
                    achievement: achievement,
                    unlocked: unlocked.contains(achievement.key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

class _AchievementBadgePreview extends StatelessWidget {
  const _AchievementBadgePreview({
    required this.achievement,
    required this.unlocked,
  });

  final ProgressMilestone achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 142,
      child: Column(
        children: [
          _AchievementBadgeImage(
            achievement: achievement,
            unlocked: unlocked,
            size: 104,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: unlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: unlocked ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            achievement.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadgeImage extends StatelessWidget {
  const _AchievementBadgeImage({
    required this.achievement,
    required this.unlocked,
    required this.size,
  });

  final ProgressMilestone achievement;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = achievement.badgeAsset;

    final badge = asset == null
        ? Icon(
            Icons.emoji_events_rounded,
            size: size * 0.62,
            color: unlocked ? AppColors.accentMoney : theme.colorScheme.outline,
          )
        : Image.asset(asset, width: size, height: size, fit: BoxFit.contain);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: unlocked
                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                : const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
            child: Opacity(opacity: unlocked ? 1 : 0.58, child: badge),
          ),
          if (!unlocked)
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.82),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: size * 0.20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
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
