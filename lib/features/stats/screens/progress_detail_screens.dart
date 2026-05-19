import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../features/progress/screens/progress_screen.dart';

class SmokeFreeDetailsScreen extends ConsumerWidget {
  const SmokeFreeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
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
      title: 'Money saved',
      dashboard: dashboard,
      builder: (context, data) {
        final daily =
            data.moneySaved /
            (data.smokeFreeDuration.inDays <= 0
                ? 1
                : data.smokeFreeDuration.inDays);
        return [
          _HeroNumber(
            value:
                '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
            label: 'estimated saved',
            color: AppColors.accentMoney,
            icon: Icons.savings_rounded,
          ),
          _InfoCard(
            title: 'This week pace',
            body:
                'At this pace, one smoke-free week is about ${data.currencySymbol}${(daily * 7).toStringAsFixed(0)} kept in your pocket.',
            icon: Icons.trending_up_rounded,
            color: AppColors.accentMoney,
          ),
          _InfoCard(
            title: 'How it is calculated',
            body:
                'Cigarettes avoided divided by pack size, multiplied by your pack price.',
            icon: Icons.calculate_rounded,
            color: AppColors.primary,
          ),
        ];
      },
    );
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
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            _HeroNumber(
              value: '${analysis.totalCravings}',
              label: 'recent craving logs',
              color: AppColors.accentCraving,
              icon: Icons.bolt_rounded,
            ),
            if (!analysis.hasEnoughData) ...[
              _InfoCard(
                title: 'A few more logs first',
                body:
                    'Log three cravings before ZeroPuff turns this into patterns. Tiny sample sizes can lie.',
                icon: Icons.hourglass_empty_rounded,
                color: AppColors.accentCraving,
              ),
              ...analysis.insights.map(
                (insight) => _InfoCard(
                  title: 'Building the map',
                  body: insight,
                  icon: Icons.map_rounded,
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
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
    return _DetailScaffold(
      title: 'Health milestones',
      dashboard: dashboard,
      builder: (context, data) {
        final next = ProgressCalculations.nextMilestone(data.smokeFreeDuration);
        return [
          if (next != null)
            _InfoCard(
              title: 'Next: ${next.title}',
              body: next.body,
              icon: Icons.flag_rounded,
              color: AppColors.accentMoney,
            ),
          ...ProgressCalculations.healthMilestones.map(
            (milestone) => _MilestoneRow(
              milestone: milestone,
              active: data.smokeFreeDuration >= milestone.duration,
            ),
          ),
        ];
      },
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
    return _DetailScaffold(
      title: 'Achievements',
      dashboard: dashboard,
      builder: (context, data) => [
        _HeroNumber(
          value: '${unlocked.length}',
          label: 'unlocked',
          color: AppColors.primary,
          icon: Icons.emoji_events_rounded,
        ),
        ...ProgressCalculations.achievements.map(
          (achievement) => _MilestoneRow(
            milestone: achievement,
            active: unlocked.contains(achievement.key),
          ),
        ),
      ],
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

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestone, required this.active});

  final ProgressMilestone milestone;
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: theme.textTheme.titleMedium),
                if (milestone.body.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    milestone.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
