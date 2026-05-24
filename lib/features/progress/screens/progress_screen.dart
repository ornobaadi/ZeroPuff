import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            120,
          ),
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
                  'See what your body is rebuilding and what you are unlocking next.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _HealthImprovementsCard(
                  smokeFreeDuration: data.smokeFreeDuration,
                  onTap: () => context.push(AppRoutes.healthDetails),
                ),
                const SizedBox(height: AppSpacing.lg),
                _AchievementShowcaseCard(
                  achievements: ProgressCalculations.achievements,
                  unlocked: unlocked,
                  onTap: () => context.push(AppRoutes.achievementsDetails),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Text('Quick stats', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.lg),
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

class _HealthImprovementsCard extends StatelessWidget {
  const _HealthImprovementsCard({
    required this.smokeFreeDuration,
    required this.onTap,
  });

  final Duration smokeFreeDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final current = ProgressCalculations.currentMilestone(smokeFreeDuration);
    final next = ProgressCalculations.nextMilestone(smokeFreeDuration);
    final hasReachedFirst =
        smokeFreeDuration >=
        ProgressCalculations.healthMilestones.first.duration;
    final shown = next ?? current;
    final previous = ProgressCalculations.previousMilestone(shown);
    final previousDuration = previous?.duration ?? Duration.zero;
    final segmentDuration = shown.duration - previousDuration;
    final segmentElapsed = smokeFreeDuration - previousDuration;
    final progress = next == null
        ? 1.0
        : (segmentElapsed.inSeconds / segmentDuration.inSeconds).clamp(
            0.0,
            1.0,
          );
    final asset = current.badgeAsset ?? shown.badgeAsset;

    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceCardDark
              : AppColors.primaryLight.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.22)
                : AppColors.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HealthAssetImage(asset: asset, active: hasReachedFirst),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health improvements',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hasReachedFirst
                            ? 'Current marker: ${current.title}'
                            : 'First marker: 20 minutes',
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
            Text(
              hasReachedFirst
                  ? current.body
                  : 'Your first body-recovery marker begins at 20 smoke-free minutes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.86),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    next == null
                        ? 'All listed markers reached'
                        : '${(progress * 100).round()}% to ${next.title}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (next != null)
                  Text(
                    next.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthAssetImage extends StatelessWidget {
  const _HealthAssetImage({required this.asset, required this.active});

  final String? asset;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = this.asset;
    final fallback = Icon(
      active ? Icons.favorite_rounded : Icons.lock_rounded,
      color: active ? AppColors.primary : theme.colorScheme.outline,
      size: 48,
    );
    final image = asset == null
        ? fallback
        : Image.asset(
            asset,
            width: 82,
            height: 82,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => fallback,
          );

    return SizedBox(
      width: 82,
      height: 82,
      child: ColorFiltered(
        colorFilter: active
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
        child: Opacity(opacity: active ? 1 : 0.54, child: image),
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
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? AppColors.accentCraving.withValues(alpha: 0.18)
                : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
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
    final isDark = theme.brightness == Brightness.dark;
    final unlockedCount = achievements
        .where((achievement) => unlocked.contains(achievement.key))
        .length;
    ProgressMilestone? nextLocked;
    for (final achievement in achievements) {
      if (!unlocked.contains(achievement.key)) {
        nextLocked = achievement;
        break;
      }
    }
    final progress = achievements.isEmpty
        ? 0.0
        : unlockedCount / achievements.length;

    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentMoney.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accentMoney,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        nextLocked == null
                            ? 'Every badge is unlocked.'
                            : 'Next badge: ${nextLocked.title}',
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
            Row(
              children: [
                Text(
                  '$unlockedCount/${achievements.length} unlocked',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.accentMoney,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: AppColors.accentMoney,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 210,
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
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.18) : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
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
              child: Text(
                value,
                style: AppTypography.statNumber.copyWith(color: color),
              ),
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
      width: 136,
      child: Column(
        children: [
          _AchievementBadgeImage(
            achievement: achievement,
            unlocked: unlocked,
            size: 94,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            achievement.title,
            maxLines: 2,
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
          Expanded(
            child: Text(
              achievement.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.32,
              ),
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
        borderRadius: BorderRadius.circular(28),
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
