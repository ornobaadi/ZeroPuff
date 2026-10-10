import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/run_calculations.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/number_formatting.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/savings_jar.dart';
import '../../../models/craving_rescue_data.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_loop_repository.dart';
import '../providers/home_dashboard_provider.dart';

/// The most coins that drop when the app is opened, however long it has been.
const _maxDrops = 5;

/// The money kept, as a jar that fills. Coins earned since the last visit drop
/// in when the app is opened, so there is something to see each day.
class JarCard extends ConsumerStatefulWidget {
  const JarCard({required this.data, required this.onTap, super.key});

  final HomeDashboardData data;
  final VoidCallback onTap;

  @override
  ConsumerState<JarCard> createState() => _JarCardState();
}

class _JarCardState extends ConsumerState<JarCard> {
  /// What the jar held the last time it was seen. Null until it is read.
  double? _seen;
  bool _seenLoaded = false;

  /// Goes up each time a craving is beaten while Home is open, so that coin
  /// is seen landing here too.
  int _plays = 0;

  @override
  void initState() {
    super.initState();
    _loadSeen();
  }

  Future<void> _loadSeen() async {
    final repository = ref.read(dailyLoopRepositoryProvider);
    double? seen;
    try {
      seen = await repository.jarSeenMoney();
      await repository.setJarSeenMoney(widget.data.moneySaved);
    } on Object {
      // Without it the jar simply shows its level with no coins dropping.
    }
    if (mounted) {
      setState(() {
        _seen = seen;
        _seenLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    ref.listen(recentCravingsProvider, (previous, next) {
      int beaten(AsyncValue<List<CravingRescueData>>? value) =>
          value?.value?.where((craving) => craving.resisted).length ?? 0;
      if (previous?.value != null && beaten(next) > beaten(previous)) {
        setState(() => _plays += 1);
      }
    });
    final data = widget.data;
    final symbol = data.currencySymbol;
    final goal = ref.watch(savingsGoalProvider).value;
    final nextTarget = SavingsTargets.next(
      saved: data.moneySaved,
      packPrice: data.packPrice,
    );

    final target = goal?.target ?? nextTarget?.amount;
    double level(double money) {
      return target == null || target <= 0
          ? 0
          : (money / target).clamp(0.0, 1.0);
    }

    final seen = _seen;
    final gained = seen == null ? 0.0 : data.moneySaved - seen;
    final perCigarette = data.packSize <= 0
        ? 0.0
        : data.packPrice / data.packSize;
    final drops = gained <= 0 || perCigarette <= 0
        ? 0
        : (gained / perCigarette).round().clamp(1, _maxDrops);

    final String targetLine;
    if (goal != null) {
      targetLine = goal.reachedWith(data.moneySaved)
          ? '${goal.name}: saved up'
          : '${(goal.progress(data.moneySaved) * 100).round()}% of ${goal.name}';
    } else if (nextTarget != null) {
      targetLine =
          'Next: ${formatMoney(symbol, nextTarget.amount)}, '
          '${nextTarget.packs} ${nextTarget.packs == 1 ? 'pack' : 'packs'} not bought';
    } else {
      targetLine = 'Set a goal to fill the jar towards';
    }

    return AppCard(
      onTap: widget.onTap,
      semanticLabel:
          'Money kept: ${formatMoney(symbol, data.moneySaved)}. '
          '${data.cigarettesAvoided} cigarettes not smoked. $targetLine. '
          'Double tap for savings.',
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 116,
            // Built once the last-seen amount is known, so the coins that
            // drop are the ones earned since then.
            child: _seenLoaded
                ? CoinDropJar(
                    fill: level(data.moneySaved),
                    drops: _plays == 0 ? drops : 1,
                    playCount: _plays,
                    hapticsEnabled: ref.watch(hapticsEnabledControllerProvider),
                  )
                : SavingsJar(fill: level(data.moneySaved)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONEY KEPT',
                  style: AppTypography.eyebrow.copyWith(color: accents.money),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatMoney(symbol, data.moneySaved),
                    style: AppTypography.statNumber.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (data.moneyToday >= 0.5)
                  Text(
                    '+${formatMoney(symbol, data.moneyToday)} today',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accents.money,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  targetLine,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Symbols.smoke_free_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${formatCount(data.cigarettesAvoided)} cigarettes not smoked',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Symbols.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
