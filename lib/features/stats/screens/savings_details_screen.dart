import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../widgets/detail_widgets.dart';

const _targets = [10.0, 25.0, 50.0, 100.0, 250.0, 500.0, 1000.0];

double? _nextSavingsTarget(double saved) {
  for (final target in _targets) {
    if (saved < target) {
      return target;
    }
  }
  return null;
}

class SavingsDetailsScreen extends ConsumerWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailScaffold(
      title: 'Money won back',
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
        final symbol = data.currencySymbol;

        return [
          DetailHero(
            value: '$symbol${data.moneySaved.toStringAsFixed(0)}',
            label: 'won back from cigarettes',
            icon: Icons.savings_rounded,
            tone: StatTone.money,
          ),
          EvenRow(
            children: [
              MiniStat(
                value: '$symbol${dailyBaseline.toStringAsFixed(0)}',
                label: 'old daily spend',
                tone: StatTone.money,
              ),
              MiniStat(
                value: packsSkipped.toStringAsFixed(1),
                label: 'packs skipped',
              ),
            ],
          ),
          _TargetCard(
            currencySymbol: symbol,
            target: nextTarget,
            progress: targetProgress,
            daysToTarget: daysToTarget,
          ),
          _ProjectionCard(currencySymbol: symbol, dailyBaseline: dailyBaseline),
          const InfoCard(
            title: 'How it is calculated',
            body:
                'We estimate cigarettes avoided from your old daily pace, then divide by pack size and multiply by your pack price.',
            icon: Icons.calculate_rounded,
          ),
          const InfoCard(
            title: 'Make it feel real',
            body:
                'Pick a small reward for the next target. The money is already moving back to you.',
            icon: Icons.redeem_rounded,
            tone: StatTone.streak,
          ),
        ];
      },
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
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
    final colors = ToneColors.of(context, StatTone.money);
    final target = this.target;
    final title = target == null
        ? 'Every money target reached'
        : 'Next money win: $currencySymbol${target.toStringAsFixed(0)}';
    final note = target == null
        ? 'You have crossed every money target we track for now.'
        : daysToTarget == null
        ? 'Keep logging and this target will sharpen.'
        : daysToTarget == 1
        ? 'At your old pace, this could land in about a day.'
        : 'At your old pace, this could land in about $daysToTarget days.';

    return AppCard(
      color: colors.container,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: colors.onContainer),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            year2023: false, // ignore: deprecated_member_use
            value: progress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(999),
            color: colors.onContainer,
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            semanticsLabel: 'Progress to next money target',
            semanticsValue: '${(progress * 100).round()} percent',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({
    required this.currencySymbol,
    required this.dailyBaseline,
  });

  final String currencySymbol;
  final double dailyBaseline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, StatTone.money);

    String amount(int days) =>
        '$currencySymbol${(dailyBaseline * days).toStringAsFixed(0)}';

    return AppCard(
      style: AppCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: colors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Projected money won back',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          EvenRow(
            children: [
              MiniStat(value: amount(7), label: 'a week', tone: StatTone.money),
              MiniStat(value: amount(30), label: 'a month', tone: StatTone.money),
              MiniStat(value: amount(365), label: 'a year', tone: StatTone.money),
            ],
          ),
        ],
      ),
    );
  }
}
