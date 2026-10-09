import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/run_calculations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/savings_jar.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_loop_repository.dart';
import '../widgets/detail_widgets.dart';
import '../../../core/utils/number_formatting.dart';

class SavingsDetailsScreen extends ConsumerWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(savingsGoalProvider).value;

    return DetailScaffold(
      title: 'Money kept',
      builder: (context, data) {
        final dailyBaseline = data.packSize <= 0
            ? 0.0
            : (data.cigarettesPerDay / data.packSize) * data.packPrice;
        final packsSkipped = data.packSize <= 0
            ? 0.0
            : data.cigarettesAvoided / data.packSize;
        final nextTarget = SavingsTargets.next(
          saved: data.moneySaved,
          packPrice: data.packPrice,
        );
        final targetProgress = nextTarget == null
            ? 1.0
            : (data.moneySaved / nextTarget.amount).clamp(0.0, 1.0);
        final daysToTarget = nextTarget == null || dailyBaseline <= 0
            ? null
            : ((nextTarget.amount - data.moneySaved) / dailyBaseline)
                  .ceil()
                  .clamp(1, 9999);
        // The jar is full at the goal, or at the next round target.
        final jarTarget = goal?.target ?? nextTarget?.amount;
        final symbol = data.currencySymbol;

        return [
          _JarHero(
            amount: formatMoney(symbol, data.moneySaved),
            fill: jarTarget == null || jarTarget <= 0
                ? 0
                : (data.moneySaved / jarTarget).clamp(0.0, 1.0),
          ),
          EvenRow(
            children: [
              MiniStat(
                value: formatMoney(symbol, dailyBaseline),
                label: 'old daily spend',
                tone: StatTone.money,
              ),
              MiniStat(
                value: formatDecimal(packsSkipped),
                label: 'packs skipped',
              ),
            ],
          ),
          if (goal == null)
            _TargetCard(
              currencySymbol: symbol,
              target: nextTarget?.amount,
              packs: nextTarget?.packs,
              progress: targetProgress,
              daysToTarget: daysToTarget,
            ),
          _GoalCard(
            goal: goal,
            saved: data.moneySaved,
            dailyBaseline: dailyBaseline,
            currencySymbol: symbol,
            onEdit: () => _editGoal(context, ref, goal, symbol),
          ),
          _ProjectionCard(currencySymbol: symbol, dailyBaseline: dailyBaseline),
          const InfoCard(
            title: 'How it is calculated',
            body:
                'Cigarettes not smoked since your quit date at your old daily pace, less any you logged, priced from your pack. A slip costs what you smoked, not everything before it.',
            icon: Symbols.calculate_rounded,
          ),
        ];
      },
    );
  }
}

Future<void> _editGoal(
  BuildContext context,
  WidgetRef ref,
  SavingsGoal? current,
  String currencySymbol,
) async {
  final result = await showModalBottomSheet<_GoalEdit>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        _GoalSheet(current: current, currencySymbol: currencySymbol),
  );
  if (result == null) {
    return;
  }
  final repository = ref.read(dailyLoopRepositoryProvider);
  final goal = result.goal;
  if (goal == null) {
    await repository.clearSavingsGoal();
  } else {
    await repository.saveSavingsGoal(goal);
  }
  ref.invalidate(savingsGoalProvider);
}

/// The result of the goal sheet: a goal to save, or none to remove it.
class _GoalEdit {
  const _GoalEdit(this.goal);

  final SavingsGoal? goal;
}

/// The thing the money is for, with a jar filling towards it.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.saved,
    required this.dailyBaseline,
    required this.currencySymbol,
    required this.onEdit,
  });

  final SavingsGoal? goal;
  final double saved;
  final double dailyBaseline;
  final String currencySymbol;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final goal = this.goal;

    if (goal == null) {
      return AppCard(
        style: AppCardStyle.outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is this money for?', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Name something you want. Every cigarette you skip moves you closer to it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onEdit,
              icon: const Icon(Symbols.flag_rounded),
              label: const Text('Set a goal'),
            ),
          ],
        ),
      );
    }

    final progress = goal.progress(saved);
    final percent = (progress * 100).round();
    final left = goal.target - saved;
    final days = dailyBaseline <= 0 || left <= 0
        ? null
        : (left / dailyBaseline).ceil();
    final note = left <= 0
        ? 'You have saved enough. Go and get it.'
        : days == null
        ? '${formatMoney(currencySymbol, left)} to go.'
        : '${formatMoney(currencySymbol, left)} to go, about $days ${days == 1 ? 'day' : 'days'} at your old pace.';

    return AppCard(
      semanticLabel:
          'Savings goal: ${goal.name}. $percent percent of ${formatMoney(currencySymbol, goal.target)}. $note',
      onTap: onEdit,
      child: Row(
        children: [
          SizedBox(width: 104, height: 120, child: SavingsJar(fill: progress)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$percent% of ${formatMoney(currencySymbol, goal.target)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ToneColors.of(context, StatTone.money).accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class _GoalSheet extends StatefulWidget {
  const _GoalSheet({required this.current, required this.currencySymbol});

  final SavingsGoal? current;
  final String currencySymbol;

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late final _name = TextEditingController(text: widget.current?.name ?? '');
  late final _amount = TextEditingController(
    text: widget.current == null
        ? ''
        : widget.current!.target.round().toString(),
  );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final target = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (name.isEmpty || target == null || target <= 0) {
      setState(() => _error = 'Add a name and how much it costs.');
      return;
    }
    Navigator.of(
      context,
    ).pop(_GoalEdit(SavingsGoal(name: name, target: target)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your savings goal', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              maxLength: 30,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'What do you want?',
                hintText: 'New headphones',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: 'How much does it cost?',
                prefixText: '${widget.currencySymbol} ',
                errorText: _error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: const Text('Save goal')),
            if (widget.current != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(const _GoalEdit(null)),
                child: const Text('Remove goal'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The money as a jar of coins. Tapping it drops a few in again.
class _JarHero extends ConsumerStatefulWidget {
  const _JarHero({required this.amount, required this.fill});

  final String amount;
  final double fill;

  @override
  ConsumerState<_JarHero> createState() => _JarHeroState();
}

class _JarHeroState extends ConsumerState<_JarHero> {
  int _plays = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, StatTone.money);

    return Semantics(
      label: '${widget.amount} kept from cigarettes',
      button: true,
      hint: 'Drops the coins in again',
      excludeSemantics: true,
      onTap: () => setState(() => _plays += 1),
      child: AppCard(
        color: colors.container,
        onTap: () => setState(() => _plays += 1),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CoinDropJar(
                fill: widget.fill,
                drops: 3,
                playCount: _plays,
                hapticsEnabled: ref.watch(hapticsEnabledControllerProvider),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.amount,
                style: AppTypography.displayNumber.copyWith(
                  color: colors.onContainer,
                ),
              ),
            ),
            Text(
              'kept from cigarettes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.currencySymbol,
    required this.target,
    required this.packs,
    required this.progress,
    required this.daysToTarget,
  });

  final String currencySymbol;
  final double? target;

  /// How many packs' worth [target] is.
  final int? packs;
  final double progress;
  final int? daysToTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, StatTone.money);
    final target = this.target;
    final packs = this.packs;
    final title = target == null
        ? 'Every money target reached'
        : packs == null
        ? 'Next money win: ${formatMoney(currencySymbol, target)}'
        : 'Next: ${formatMoney(currencySymbol, target)}, $packs ${packs == 1 ? 'pack' : 'packs'} not bought';
    final note = target == null
        ? 'You have crossed every money target we track for now.'
        : daysToTarget == null
        ? 'Keep logging and this target will sharpen.'
        : daysToTarget == 1
        ? 'At your old pace, this could land in about a day.'
        : 'At your old pace, this could land in about $daysToTarget days.';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.flag_rounded, color: colors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: colors.accent,
            semanticsLabel: 'Progress to next money target',
            semanticsValue: '${(progress * 100).round()} percent',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
        formatMoney(currencySymbol, (dailyBaseline * days).roundToDouble());

    return AppCard(
      style: AppCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.auto_graph_rounded, color: colors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'What it adds up to',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          EvenRow(
            children: [
              MiniStat(value: amount(7), label: 'a week', tone: StatTone.money),
              MiniStat(
                value: amount(30),
                label: 'a month',
                tone: StatTone.money,
              ),
              MiniStat(
                value: amount(365),
                label: 'a year',
                tone: StatTone.money,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
