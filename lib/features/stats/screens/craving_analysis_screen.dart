import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/calculations/craving_analysis_calculations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../widgets/detail_widgets.dart';

class CravingAnalysisScreen extends ConsumerWidget {
  const CravingAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cravings = ref.watch(recentCravingsProvider);
    final smokingLogs = ref.watch(recentSmokingLogsProvider);

    void retry() {
      ref.invalidate(recentCravingsProvider);
      ref.invalidate(recentSmokingLogsProvider);
    }

    final Widget body;
    if (cravings.hasError || smokingLogs.hasError) {
      body = StateView.error(
        error: cravings.error ?? smokingLogs.error!,
        onRetry: retry,
      );
    } else if (cravings.isLoading || smokingLogs.isLoading) {
      body = const StateView.loading();
    } else {
      final analysis = CravingAnalysisCalculations.analyze(
        cravings: cravings.value ?? const [],
        smokingLogs: smokingLogs.value ?? const [],
        now: DateTime.now(),
      );
      body = DetailList(
        children: analysis.hasEnoughData
            ? _insights(context, analysis)
            : [_WarmingUp(totalCravings: analysis.totalCravings)],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Craving analysis')),
      body: SafeArea(child: body),
    );
  }

  List<Widget> _insights(BuildContext context, CravingAnalysisData analysis) {
    return [
      DetailHero(
        value: '${analysis.totalCravings}',
        label: 'recent craving logs',
        icon: Symbols.bolt_rounded,
        tone: StatTone.craving,
      ),
      _InsightList(insights: analysis.insights),
      EvenRow(
        children: [
          MiniStat(
            value: '${(analysis.resistanceRate * 100).round()}%',
            label: 'resisted',
          ),
          MiniStat(
            value: analysis.averageIntensity.toStringAsFixed(1),
            label: 'avg intensity',
            tone: StatTone.streak,
          ),
        ],
      ),
      EvenRow(
        children: [
          MiniStat(
            value: '${analysis.cravingsThisWeek}',
            label: 'this week',
            tone: StatTone.craving,
          ),
          MiniStat(
            value: '${analysis.smokeFreeDaysThisMonth}',
            label: 'clean days this month',
            tone: StatTone.money,
          ),
        ],
      ),
      InfoCard(
        title: 'Hardest window',
        body: analysis.peakWindow == null
            ? 'No clear time window yet.'
            : '${analysis.peakWindow!.label} has the most logged cravings.',
        icon: Symbols.schedule_rounded,
        tone: StatTone.craving,
      ),
      if (analysis.topTriggers.isNotEmpty) ...[
        const SectionHeader(title: 'Top triggers'),
        for (final trigger in analysis.topTriggers)
          _TriggerRow(trigger: trigger),
      ],
    ];
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, StatTone.craving);

    return AppCard(
      color: colors.container,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.insights_rounded, color: colors.onContainer),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                header: true,
                child: Text(
                  'Today’s read',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.onContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: 6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      insight,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onContainer,
                      ),
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

class _WarmingUp extends StatelessWidget {
  const _WarmingUp({required this.totalCravings});

  final int totalCravings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, StatTone.craving);
    final remaining = (3 - totalCravings).clamp(0, 3);

    return AppCard(
      color: colors.container,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.bolt_rounded, color: colors.onContainer, size: 32),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '$totalCravings / 3 logs',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onContainer,
              fontFeatures: AppTypography.lining,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Craving map warming up',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            remaining == 1
                ? 'Log one more craving to unlock useful patterns. Tiny sample sizes can lie.'
                : 'Log $remaining more cravings to unlock useful patterns. Tiny sample sizes can lie.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: (totalCravings / 3).clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: colors.onContainer,
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            semanticsLabel: 'Craving logs so far',
            semanticsValue: '$totalCravings of 3',
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
    final colors = ToneColors.of(context, StatTone.craving);
    final name = toBeginningOfSentenceCase(trigger.trigger);

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel: '$name, ${trigger.count} times',
      child: Row(
        children: [
          Icon(Symbols.label_rounded, color: colors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: theme.textTheme.titleMedium)),
          Text(
            '${trigger.count}×',
            style: theme.textTheme.titleMedium?.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}
