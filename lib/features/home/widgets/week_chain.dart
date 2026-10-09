import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/run_calculations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/day_dot.dart';

/// The last seven days as a row of marks, with the current run. The top opens
/// the streak page; the line under it says where today stands and seals it.
class WeekChain extends StatelessWidget {
  const WeekChain({
    required this.history,
    required this.onTap,
    this.onSeal,
    this.sealOffered = true,
    super.key,
  });

  final DayHistory history;
  final VoidCallback onTap;

  /// Opens the seal. Leave null when something else on screen already offers
  /// it.
  final VoidCallback? onSeal;

  /// False during the day on Home, where the morning promise is the one
  /// thing asked for and the seal waits for the evening.
  final bool sealOffered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final days = history.lastDays(7);
    final run = history.currentRun;
    final clear = days.where((day) => day.smokeFree && !day.isToday).length;
    final slips = days.where((day) => day.slipped).length;
    final todayLine = RunCalculations.todayLine(
      history,
      sealOffered: sealOffered,
    );
    final onSeal = history.sealedToday ? null : this.onSeal;

    return AppCard(
      style: AppCardStyle.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Semantics(
            label:
                'Last seven days: $clear smoke-free, $slips with a cigarette. '
                'Current run $run ${run == 1 ? 'day' : 'days'}. '
                'Double tap for your streak.',
            button: true,
            excludeSemantics: true,
            onTap: onTap,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'This week',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          run == 1 ? '1 day run' : '$run day run',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                        Icon(
                          Symbols.chevron_right_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.componentGap),
                    Row(
                      children: [
                        for (final day in days)
                          Expanded(
                            child: Column(
                              children: [
                                DayDot(state: day),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  DateFormat.E()
                                      .format(day.date)
                                      .substring(0, 1),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: day.isToday
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                    fontWeight: day.isToday
                                        ? FontWeight.w700
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (todayLine != null) ...[
            Divider(height: 1, color: scheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      todayLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onSeal != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: onSeal,
                      child: const Text('Seal today'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
