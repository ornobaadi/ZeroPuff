import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../features/progress/screens/progress_screen.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';

class SmokeFreeDetailsScreen extends ConsumerWidget {
  const SmokeFreeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);
    return _DetailScaffold(
      title: 'Smoke-free time',
      dashboard: dashboard,
      builder: (context, data) => [
        _HeroNumber(
          value: '${data.smokeFreeDays}',
          label: data.smokeFreeDays == 1 ? 'day smoke-free' : 'days smoke-free',
          color: AppColors.primary,
          icon: Icons.air_rounded,
        ),
        _InfoCard(
          title: 'Right now',
          body:
              '${data.smokeFreeHours}h ${data.smokeFreeMinutes}m ${data.smokeFreeSeconds}s inside the current day.',
          icon: Icons.schedule_rounded,
          color: AppColors.primary,
        ),
        _InfoCard(
          title: 'How it is calculated',
          body:
              'This starts from your quit date, or from the latest cigarette you honestly logged.',
          icon: Icons.calculate_rounded,
          color: AppColors.accentMoney,
        ),
        _TapInfoCard(
          title: 'Recovery milestones',
          body: 'See what has already changed and what marker is coming next.',
          icon: Icons.favorite_rounded,
          color: AppColors.accentStreak,
          onTap: () {
            HapticService.selection(enabled: hapticsEnabled);
            context.push(AppRoutes.healthDetails);
          },
        ),
        _InfoCard(
          title: 'Life won back',
          body:
              'Because of those avoided cigarettes, you have protected about ${data.lifeWonBackLabel} of life. This is an estimate, not a medical prediction.',
          icon: Icons.favorite_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class SavingsDetailsScreen extends ConsumerWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return _DetailScaffold(
      title: 'Money won back',
      dashboard: dashboard,
      builder: (context, data) {
        final dailyBaseline = data.packSize <= 0
            ? 0.0
            : (data.cigarettesPerDay / data.packSize) * data.packPrice;
        final packsSkipped = data.packSize <= 0
            ? 0.0
            : data.cigarettesAvoided / data.packSize;
        final nextTarget = _nextSavingsTarget(data.moneySaved);
        final targetProgress = nextTarget == null
            ? 1.0
            : (data.moneySaved / nextTarget).clamp(0.0, 1.0);
        final daysToTarget = nextTarget == null || dailyBaseline <= 0
            ? null
            : ((nextTarget - data.moneySaved) / dailyBaseline).ceil().clamp(
                1,
                9999,
              );

        return [
          _HeroNumber(
            value:
                '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
            label: 'won back from cigarettes',
            color: AppColors.accentMoney,
            icon: Icons.savings_rounded,
          ),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value:
                      '${data.currencySymbol}${dailyBaseline.toStringAsFixed(0)}',
                  label: 'old daily spend',
                  color: AppColors.accentMoney,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  value: packsSkipped.toStringAsFixed(1),
                  label: 'packs skipped',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          _SavingsTargetCard(
            currencySymbol: data.currencySymbol,
            target: nextTarget,
            progress: targetProgress,
            daysToTarget: daysToTarget,
          ),
          _SavingsProjectionCard(
            currencySymbol: data.currencySymbol,
            dailyBaseline: dailyBaseline,
          ),
          _InfoCard(
            title: 'How it is calculated',
            body:
                'We estimate cigarettes avoided from your old daily pace, then divide by pack size and multiply by your pack price.',
            icon: Icons.calculate_rounded,
            color: AppColors.primary,
          ),
          _InfoCard(
            title: 'Make it feel real',
            body:
                'Pick a small reward for the next target. The money is already moving back to you.',
            icon: Icons.redeem_rounded,
            color: AppColors.accentStreak,
          ),
        ];
      },
    );
  }

  double? _nextSavingsTarget(double saved) {
    const targets = [10.0, 25.0, 50.0, 100.0, 250.0, 500.0, 1000.0];
    for (final target in targets) {
      if (saved < target) {
        return target;
      }
    }
    return null;
  }
}

class AvoidedDetailsScreen extends ConsumerWidget {
  const AvoidedDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return _DetailScaffold(
      title: 'Cigarettes avoided',
      dashboard: dashboard,
      builder: (context, data) => [
        _HeroNumber(
          value: '${data.cigarettesAvoided}',
          label: 'not smoked',
          color: AppColors.accentStreak,
          icon: Icons.smoke_free_rounded,
        ),
        _InfoCard(
          title: 'What this means',
          body:
              'This is an estimate based on your old daily baseline and how long you have been smoke-free.',
          icon: Icons.insights_rounded,
          color: AppColors.accentStreak,
        ),
        _InfoCard(
          title: 'Life won back',
          body:
              'Those avoided cigarettes equal about ${data.lifeWonBackLabel} of estimated healthy time protected.',
          icon: Icons.favorite_rounded,
          color: AppColors.primary,
        ),
        _InfoCard(
          title: 'Next action',
          body:
              'When a craving hits, open rescue before deciding. That is how this number keeps climbing.',
          icon: Icons.air_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class CravingAnalysisScreen extends ConsumerWidget {
  const CravingAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cravings = ref.watch(recentCravingsProvider);
    final smokingLogs = ref.watch(recentSmokingLogsProvider);

    if (cravings is AsyncLoading || smokingLogs is AsyncLoading) {
      return const Scaffold(
        appBar: _SimpleAppBar(title: 'Craving analysis'),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (cravings is AsyncError) {
      return _ErrorScaffold(title: 'Craving analysis', error: cravings.error!);
    }
    if (smokingLogs is AsyncError) {
      return _ErrorScaffold(
        title: 'Craving analysis',
        error: smokingLogs.error!,
      );
    }

    final analysis = CravingAnalysisCalculations.analyze(
      cravings: cravings.value ?? const [],
      smokingLogs: smokingLogs.value ?? const [],
      now: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Craving analysis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.lg,
          ),
          children: [
            if (!analysis.hasEnoughData) ...[
              _CravingEmptyState(totalCravings: analysis.totalCravings),
            ] else ...[
              _CompactHeroNumber(
                value: '${analysis.totalCravings}',
                label: 'recent craving logs',
                color: AppColors.accentCraving,
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightList(insights: analysis.insights),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: '${(analysis.resistanceRate * 100).round()}%',
                      label: 'resisted',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MiniStat(
                      value: analysis.averageIntensity.toStringAsFixed(1),
                      label: 'avg intensity',
                      color: AppColors.accentStreak,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: '${analysis.cravingsThisWeek}',
                      label: 'this week',
                      color: AppColors.accentCraving,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MiniStat(
                      value: '${analysis.smokeFreeDaysThisMonth}',
                      label: 'clean days this month',
                      color: AppColors.accentMoney,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                title: 'Hardest window',
                body: analysis.peakWindow == null
                    ? 'No clear time window yet.'
                    : '${analysis.peakWindow!.label} has the most logged cravings.',
                icon: Icons.schedule_rounded,
                color: AppColors.accentCraving,
              ),
              if (analysis.topTriggers.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Top triggers', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                ...analysis.topTriggers.map(
                  (trigger) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _TriggerRow(trigger: trigger),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class HealthMilestoneDetailsScreen extends ConsumerWidget {
  const HealthMilestoneDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);
    return _DetailScaffold(
      title: 'Health improvements',
      dashboard: dashboard,
      builder: (context, data) {
        final next = ProgressCalculations.nextMilestone(data.smokeFreeDuration);
        final current = ProgressCalculations.currentMilestone(
          data.smokeFreeDuration,
        );
        final shown = next ?? current;
        final previous = ProgressCalculations.previousMilestone(shown);
        final previousDuration = previous?.duration ?? Duration.zero;
        final segmentDuration = shown.duration - previousDuration;
        final segmentElapsed = data.smokeFreeDuration - previousDuration;
        final progress = next == null
            ? 1.0
            : (segmentElapsed.inSeconds / segmentDuration.inSeconds).clamp(
                0.0,
                1.0,
              );

        return [
          _HeroNumber(
            value: data.lifeWonBackLabel,
            label: 'estimated healthy time protected',
            color: AppColors.primary,
            icon: Icons.favorite_rounded,
          ),
          _HealthHero(
            current: current,
            next: next,
            progress: progress,
            smokeFreeDuration: data.smokeFreeDuration,
          ),
          _InfoCard(
            title: next == null ? 'All listed markers reached' : 'Next up',
            body: next == null
                ? 'You have cleared every current health marker in ZeroPuff.'
                : '${next.title}: ${next.body}',
            icon: next == null
                ? Icons.emoji_events_rounded
                : Icons.flag_rounded,
            color: AppColors.accentMoney,
          ),
          Text('Recovery map', style: Theme.of(context).textTheme.titleLarge),
          ...ProgressCalculations.healthMilestones.map(
            (milestone) => _HealthMilestoneCard(
              milestone: milestone,
              active: data.smokeFreeDuration >= milestone.duration,
              current: current.key == milestone.key,
              progress: ProgressCalculations.milestoneProgress(
                smokeFreeDuration: data.smokeFreeDuration,
                milestone: milestone,
              ),
              onTap: data.smokeFreeDuration >= milestone.duration
                  ? () {
                      HapticService.light(enabled: hapticsEnabled);
                      _showHealthMilestoneDialog(context, milestone);
                    }
                  : null,
            ),
          ),
          _InfoCard(
            title: 'A gentle note',
            body:
                'Health timelines are estimates. Your body, history, and care all matter, so use this as encouragement rather than diagnosis.',
            icon: Icons.favorite_rounded,
            color: AppColors.accentStreak,
          ),
          _InfoCard(
            title: 'Life won back estimate',
            body:
                'ZeroPuff estimates life won back as avoided cigarettes x 20 minutes. This is a population-level estimate, not a medical prediction.',
            icon: Icons.calculate_rounded,
            color: AppColors.accentMoney,
          ),
          _InfoCard(
            title: 'What this is based on',
            body:
                'The life estimate follows UCL research on life expectancy per cigarette. Health benefits follow public-health guidance from CDC and related clinical sources.',
            icon: Icons.verified_outlined,
            color: AppColors.primary,
          ),
        ];
      },
    );
  }

  void _showHealthMilestoneDialog(
    BuildContext context,
    ProgressMilestone milestone,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _HealthMilestoneDetailDialog(milestone: milestone),
    );
  }
}

class _SavingsTargetCard extends StatelessWidget {
  const _SavingsTargetCard({
    required this.currencySymbol,
    required this.target,
    required this.progress,
    required this.daysToTarget,
  });

  final String currencySymbol;
  final double? target;
  final double progress;
  final int? daysToTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = this.target;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.accentMoney.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accentMoney.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.accentMoney),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  target == null
                      ? 'Money win legend'
                      : 'Next money win: $currencySymbol${target.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: AppColors.accentMoney,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            target == null
                ? 'You have crossed every money target we track for now.'
                : daysToTarget == null
                ? 'Keep logging and this target will sharpen.'
                : daysToTarget == 1
                ? 'At your old pace, this could land in about a day.'
                : 'At your old pace, this could land in about $daysToTarget days.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsProjectionCard extends StatelessWidget {
  const _SavingsProjectionCard({
    required this.currencySymbol,
    required this.dailyBaseline,
  });

  final String currencySymbol;
  final double dailyBaseline;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.accentMoney,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Projected money won back',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ProjectionTile(
                  label: 'week',
                  value:
                      '$currencySymbol${(dailyBaseline * 7).toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ProjectionTile(
                  label: 'month',
                  value:
                      '$currencySymbol${(dailyBaseline * 30).toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ProjectionTile(
                  label: 'year',
                  value:
                      '$currencySymbol${(dailyBaseline * 365).toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectionTile extends StatelessWidget {
  const _ProjectionTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentMoney.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({
    required this.current,
    required this.next,
    required this.progress,
    required this.smokeFreeDuration,
  });

  final ProgressMilestone current;
  final ProgressMilestone? next;
  final double progress;
  final Duration smokeFreeDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = this.next;
    final reachedCurrent = smokeFreeDuration >= current.duration;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MilestoneBadge(
                milestone: current,
                active: reachedCurrent,
                size: 88,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reachedCurrent ? 'Current marker' : 'First target',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(current.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reachedCurrent
                          ? current.body
                          : 'Your first body-recovery marker begins at 20 smoke-free minutes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            next == null
                ? '${_durationLabel(smokeFreeDuration)} smoke-free'
                : '${(progress * 100).round()}% to ${next.title}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMilestoneCard extends StatelessWidget {
  const _HealthMilestoneCard({
    required this.milestone,
    required this.active,
    required this.current,
    required this.progress,
    required this.onTap,
  });

  final ProgressMilestone milestone;
  final bool active;
  final bool current;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? AppColors.primary : theme.colorScheme.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: current
                ? AppColors.accentMoney.withValues(alpha: 0.42)
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            _MilestoneBadge(milestone: milestone, active: active, size: 70),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _StatusPill(active: active, current: current),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    milestone.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: active ? AppColors.primary : AppColors.accentMoney,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _durationLabel(milestone.duration),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (active)
                        Icon(
                          Icons.open_in_full_rounded,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthMilestoneDetailDialog extends StatelessWidget {
  const _HealthMilestoneDetailDialog({required this.milestone});

  final ProgressMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MilestoneBadge(milestone: milestone, active: true, size: 190),
            const SizedBox(height: AppSpacing.lg),
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Unlocked at ${_durationLabel(milestone.duration)} smoke-free',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              milestone.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({
    required this.milestone,
    required this.active,
    required this.size,
  });

  final ProgressMilestone milestone;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = milestone.badgeAsset;
    final badge = asset == null
        ? Icon(
            active ? Icons.favorite_rounded : Icons.lock_rounded,
            size: size * 0.46,
            color: active ? AppColors.primary : theme.colorScheme.outline,
          )
        : Image.asset(asset, width: size, height: size, fit: BoxFit.contain);

    return SizedBox(
      width: size,
      height: size,
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
        child: Opacity(opacity: active ? 1 : 0.5, child: badge),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active, required this.current});

  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = current
        ? 'now'
        : active
        ? 'done'
        : 'next';
    final color = current
        ? AppColors.accentMoney
        : active
        ? AppColors.primary
        : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.accentCraving.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.accentCraving.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.accentCraving,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Today’s read',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _BulletLine(text: insight),
            ),
          ),
        ],
      ),
    );
  }
}

class _CravingEmptyState extends StatelessWidget {
  const _CravingEmptyState({required this.totalCravings});

  final int totalCravings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = 3 - totalCravings;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.accentCraving.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.accentCraving.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.bolt_rounded,
            color: AppColors.accentCraving,
            size: 34,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '$totalCravings / 3 logs',
            style: AppTypography.statNumber.copyWith(
              fontSize: 30,
              color: AppColors.accentCraving,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Craving map warming up', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            remaining == 1
                ? 'Log one more craving to unlock useful patterns. Tiny sample sizes can lie.'
                : 'Log $remaining more cravings to unlock useful patterns. Tiny sample sizes can lie.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: (totalCravings / 3).clamp(0, 1),
              color: AppColors.accentCraving,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeroNumber extends StatelessWidget {
  const _CompactHeroNumber({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: AppTypography.statNumber.copyWith(
              fontSize: 30,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.accentCraving,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.statNumber.copyWith(
                fontSize: 26,
                color: color,
              ),
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
    );
  }
}

class _TriggerRow extends StatelessWidget {
  const _TriggerRow({required this.trigger});

  final CravingTriggerStat trigger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.label_rounded, color: AppColors.accentCraving),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(trigger.trigger, style: theme.textTheme.titleMedium),
          ),
          Text(
            '${trigger.count}x',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.accentCraving,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SimpleAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.title, required this.error});

  final String title;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementsDetailsScreen extends ConsumerWidget {
  const AchievementsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const {};
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);
    final catalogUnlocked = ProgressCalculations.achievements
        .where((achievement) => unlocked.contains(achievement.key))
        .length;
    return _DetailScaffold(
      title: 'Achievements',
      dashboard: dashboard,
      builder: (context, data) => [
        _AchievementSummaryPill(
          unlocked: catalogUnlocked,
          total: ProgressCalculations.achievements.length,
        ),
        _AchievementGrid(
          achievements: ProgressCalculations.achievements,
          unlocked: unlocked,
          hapticsEnabled: hapticsEnabled,
        ),
      ],
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({
    required this.achievements,
    required this.unlocked,
    required this.hapticsEnabled,
  });

  final List<ProgressMilestone> achievements;
  final Set<String> unlocked;
  final bool hapticsEnabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        return GridView.builder(
          itemCount: achievements.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: columns == 3 ? 0.9 : 0.84,
          ),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _AchievementBadgeCard(
              achievement: achievement,
              unlocked: unlocked.contains(achievement.key),
              onTap: unlocked.contains(achievement.key)
                  ? () {
                      HapticService.light(enabled: hapticsEnabled);
                      _showAchievementDialog(context, achievement);
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  void _showAchievementDialog(
    BuildContext context,
    ProgressMilestone achievement,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _AchievementDetailDialog(achievement: achievement),
    );
  }
}

class _AchievementSummaryPill extends StatelessWidget {
  const _AchievementSummaryPill({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.componentGap,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$unlocked/$total unlocked',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadgeCard extends StatelessWidget {
  const _AchievementBadgeCard({
    required this.achievement,
    required this.unlocked,
    required this.onTap,
  });

  final ProgressMilestone achievement;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: unlocked
                ? AppColors.primary.withValues(alpha: 0.24)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DetailBadgeImage(
              achievement: achievement,
              unlocked: unlocked,
              size: 116,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: unlocked
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementDetailDialog extends StatelessWidget {
  const _AchievementDetailDialog({required this.achievement});

  final ProgressMilestone achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailBadgeImage(
              achievement: achievement,
              unlocked: true,
              size: 190,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBadgeImage extends StatelessWidget {
  const _DetailBadgeImage({
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
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.84),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: size * 0.18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckInDetailsScreen extends ConsumerWidget {
  const CheckInDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentCheckInsProvider);
    final dashboard = ref.watch(homeDashboardProvider);
    return _DetailScaffold(
      title: 'Check-ins',
      dashboard: dashboard,
      builder: (context, data) {
        final rows = recent.value ?? const [];
        final smokeFree = rows.where((row) => row.smokeFreeToday).length;
        return [
          _HeroNumber(
            value: '${rows.length}',
            label: 'recent check-ins',
            color: AppColors.accentCraving,
            icon: Icons.fact_check_rounded,
          ),
          _InfoCard(
            title: 'Smoke-free check-ins',
            body: rows.isEmpty
                ? 'No check-ins yet. Start with today.'
                : '$smokeFree of your last ${rows.length} check-ins were marked smoke-free.',
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
          ),
          _InfoCard(
            title: 'Why this matters',
            body:
                'Daily logs make the calendar useful. Even a hard day becomes data you can recover from.',
            icon: Icons.calendar_month_rounded,
            color: AppColors.accentMoney,
          ),
        ];
      },
    );
  }
}

typedef _DetailBuilder =
    List<Widget> Function(BuildContext context, HomeDashboardData data);

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.title,
    required this.dashboard,
    required this.builder,
  });

  final String title;
  final AsyncValue<HomeDashboardData> dashboard;
  final _DetailBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: dashboard.when(
            data: (data) => [
              ...builder(context, data).expand(
                (widget) => [widget, const SizedBox(height: AppSpacing.md)],
              ),
            ],
            loading: () => [
              const SizedBox(height: 160),
              const Center(child: CircularProgressIndicator()),
            ],
            error: (error, _) => [
              Text('Unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroNumber extends StatelessWidget {
  const _HeroNumber({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: AppTypography.displayNumber.copyWith(
              fontSize: 64,
              color: color,
            ),
          ),
          Text(label, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
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

class _TapInfoCard extends StatelessWidget {
  const _TapInfoCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
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
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
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

String _durationLabel(Duration duration) {
  if (duration.inDays >= 365) {
    final years = duration.inDays ~/ 365;
    return years == 1 ? '1 year' : '$years years';
  }
  if (duration.inDays >= 30) {
    final months = duration.inDays ~/ 30;
    return months == 1 ? '1 month' : '$months months';
  }
  if (duration.inDays >= 1) {
    return duration.inDays == 1 ? '1 day' : '${duration.inDays} days';
  }
  if (duration.inHours >= 1) {
    return duration.inHours == 1 ? '1 hour' : '${duration.inHours} hours';
  }
  return duration.inMinutes == 1 ? '1 minute' : '${duration.inMinutes} minutes';
}
