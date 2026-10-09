import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/perspective_calculations.dart';
import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/number_formatting.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/craving_rescue_data.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../stats/screens/milestone_details_screen.dart' show milestoneIcon;
import '../providers/milestone_providers.dart';
import '../widgets/badge_image.dart';

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
        bottom: false,
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
    final cravings = ref.watch(recentCravingsProvider).value ?? const [];
    final history = ref.watch(dayHistoryProvider);
    final stats =
        ref.watch(milestoneStatsProvider) ??
        MilestoneStats(
          smokeFreeDuration: data.smokeFreeDuration,
          cigarettesAvoided: data.cigarettesAvoided,
        );
    final unlocked =
        ref.watch(unlockedMilestonesProvider).value ??
        const <String, DateTime?>{};

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.pagePadding,
        AppSpacing.pagePadding,
        // Clears the floating navigation bar the page scrolls under.
        AppSpacing.pagePadding + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where you stand, and what comes next.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MilestonesCard(
                stats: stats,
                unlocked: unlocked.keys.toSet(),
                onTap: () => onOpen(AppRoutes.milestoneDetails),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(title: 'Quick stats'),
              _QuickStats(
                data: data,
                history: history,
                cravings: cravings,
                onOpen: onOpen,
              ),
              const SizedBox(height: AppSpacing.md),
              _PerspectiveCard(
                facts: PerspectiveCalculations.facts(
                  cigarettesAvoided: data.cigarettesAvoided,
                  packSize: data.packSize,
                  cravingsBeaten: stats.cravingsBeaten,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CravingAnalysisCard(
                cravingCount: cravings.length,
                onTap: () => onOpen(AppRoutes.cravingAnalysis),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Six numbers, each with a second line that says something about today or
/// puts the number in context.
class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.data,
    required this.history,
    required this.cravings,
    required this.onOpen,
  });

  final HomeDashboardData data;
  final DayHistory? history;
  final List<CravingRescueData> cravings;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final history = this.history;
    final beaten = cravings.where((craving) => craving.resisted).length;
    final finished = cravings
        .where((craving) => craving.outcome != 'unknown')
        .length;
    final run = history?.currentRun ?? data.smokeFreeStreakDays;
    final best = history?.bestRun ?? run;
    final smokeFreeDays = history?.smokeFreeDays ?? data.smokeFreeDays;

    return Column(
      children: [
        _StatRow(
          left: StatCard(
            label: 'Smoke-free days',
            value: '$smokeFreeDays',
            delta: history == null
                ? null
                : 'since ${DateFormat.MMMd().format(history.quitDay)}',
            icon: Symbols.air_rounded,
            onTap: () => onOpen(AppRoutes.smokeFreeDetails),
          ),
          right: StatCard(
            label: 'Money kept',
            value: formatMoney(data.currencySymbol, data.moneySaved),
            delta: data.moneyToday >= 0.5
                ? '+${formatMoney(data.currencySymbol, data.moneyToday)} today'
                : null,
            icon: Symbols.savings_rounded,
            tone: StatTone.money,
            onTap: () => onOpen(AppRoutes.savingsDetails),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatRow(
          left: StatCard(
            label: 'Not smoked',
            value: formatCount(data.cigarettesAvoided),
            delta: data.cigarettesAvoidedToday > 0
                ? '+${data.cigarettesAvoidedToday} today'
                : null,
            icon: Symbols.smoke_free_rounded,
            tone: StatTone.streak,
            onTap: () => onOpen(AppRoutes.avoidedDetails),
          ),
          right: StatCard(
            label: 'Cravings beaten',
            value: '$beaten',
            delta: finished == 0
                ? null
                : '${(beaten / finished * 100).round()}% won',
            icon: Symbols.bolt_rounded,
            tone: StatTone.craving,
            onTap: () => onOpen(AppRoutes.cravingAnalysis),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatRow(
          left: StatCard(
            label: 'Best run',
            value: best == 1 ? '1 day' : '$best days',
            delta: 'now on $run',
            icon: Symbols.local_fire_department_rounded,
            tone: StatTone.streak,
            onTap: () => onOpen(AppRoutes.streakDetails),
          ),
          right: StatCard(
            label: 'Time not smoking',
            value: PerspectiveCalculations.timeNotSmoking(
              data.cigarettesAvoided,
            ),
            delta:
                'about ${PerspectiveCalculations.minutesPerCigarette} min each',
            icon: Symbols.timer_rounded,
            onTap: () => onOpen(AppRoutes.avoidedDetails),
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

/// How many milestones are reached, the next one by time, and the ones
/// closest to being reached.
class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({
    required this.stats,
    required this.unlocked,
    required this.onTap,
  });

  final MilestoneStats stats;
  final Set<String> unlocked;
  final VoidCallback onTap;

  bool _reached(ProgressMilestone milestone) {
    return unlocked.contains(milestone.key) || milestone.isUnlocked(stats);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.onPrimaryContainer;
    const all = ProgressCalculations.milestones;
    final reached = all.where(_reached).length;
    final next = ProgressCalculations.nextMilestone(stats.smokeFreeDuration);
    // The three that are nearest to done, whatever kind they are.
    final closest = all.where((milestone) => !_reached(milestone)).toList()
      ..sort((a, b) => b.progress(stats).compareTo(a.progress(stats)));
    final nextLine = next == null
        ? 'Every time milestone reached'
        : 'Next: ${next.title}, ${next.progressLabel(stats)}';

    return AppCard(
      style: AppCardStyle.tonal,
      onTap: onTap,
      semanticLabel:
          'Milestones. $reached of ${all.length} reached. $nextLine. '
          'Double tap for details.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestones',
                      style: theme.textTheme.titleLarge?.copyWith(color: color),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      nextLine,
                      style: theme.textTheme.bodyMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right_rounded, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$reached of ${all.length} reached',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: all.isEmpty ? 0 : reached / all.length,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: scheme.surface.withValues(alpha: 0.5),
            semanticsLabel: 'Milestones reached',
            semanticsValue: '$reached of ${all.length}',
          ),
          if (closest.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Closest',
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final milestone in closest.take(3))
                  Expanded(
                    child: Column(
                      children: [
                        BadgeImage(
                          asset: milestone.badgeAsset,
                          unlocked: false,
                          size: 56,
                          showLock: false,
                          fallbackIcon: milestoneIcon(milestone),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          milestone.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                          ),
                        ),
                        Text(
                          milestone.progressLabel(stats) ?? 'not yet',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A plain way of picturing the totals. Tapping moves to the next one.
class _PerspectiveCard extends StatefulWidget {
  const _PerspectiveCard({required this.facts});

  final List<String> facts;

  @override
  State<_PerspectiveCard> createState() => _PerspectiveCardState();
}

class _PerspectiveCardState extends State<_PerspectiveCard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final facts = widget.facts;
    if (facts.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fact = facts[_index % facts.length];
    final several = facts.length > 1;

    return AppCard(
      style: AppCardStyle.outlined,
      onTap: several ? () => setState(() => _index += 1) : null,
      semanticLabel:
          'In perspective. $fact${several ? ' Double tap for another.' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IN PERSPECTIVE',
            style: AppTypography.eyebrow.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(fact, style: theme.textTheme.titleMedium),
          if (several) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap for another',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
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
                Symbols.insights_rounded,
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
          const Icon(Symbols.chevron_right_rounded),
        ],
      ),
    );
  }
}
