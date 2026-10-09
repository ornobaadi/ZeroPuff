import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/run_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/day_dot.dart';
import '../../../core/widgets/stat_card.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../../journal/providers/journal_providers.dart';
import '../../share/share_card.dart';
import '../widgets/detail_widgets.dart';

/// Weeks shown in the chain, ending with the current one.
const _chainWeeks = 5;

class StreakDetailsScreen extends ConsumerWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(dayHistoryProvider);
    final logs = ref.watch(recentSmokingLogsProvider).value ?? const [];

    return DetailScaffold(
      title: 'Smoke-free run',
      builder: (context, data) {
        final run = history?.currentRun ?? data.smokeFreeStreakDays;
        final insight = history == null
            ? null
            : RunCalculations.runEndInsight(
                runEnds: history.runEnds,
                slipTimes: logs.map((log) => log.smokedAt).toList(),
              );

        final todayLine = history == null
            ? null
            : RunCalculations.todayLine(history);

        return [
          _RunHero(run: run, since: history?.runStart, best: history?.bestRun),
          if (todayLine != null)
            _Today(
              line: todayLine,
              onSeal: data.todaySealed
                  ? null
                  : () => context.push(AppRoutes.checkIn),
            ),
          if (history != null)
            _Chain(
              history: history,
              onDay: (day) {
                // Open the journal on that day.
                ref.read(journalMonthProvider.notifier).show(day);
                ref.read(selectedJournalDayProvider.notifier).select(day);
                context.go(AppRoutes.journal);
              },
            ),
          if (history != null)
            EvenRow(
              children: [
                MiniStat(
                  value: '${history.bestRun}',
                  label: 'best run',
                  tone: StatTone.streak,
                ),
                MiniStat(
                  value: '${history.smokeFreeDays}',
                  label: 'smoke-free days',
                ),
                MiniStat(
                  value: '${history.sealedCount}',
                  label: 'days sealed',
                  tone: StatTone.craving,
                ),
              ],
            ),
          _NextTarget(run: run),
          if (insight != null)
            InfoCard(
              title: 'A pattern worth knowing',
              body: insight,
              icon: Symbols.insights_rounded,
              tone: StatTone.craving,
            ),
          const InfoCard(
            title: 'How the run works',
            body:
                'Every day counts as smoke-free unless you log a cigarette, so there is nothing you have to confirm. Today joins your run at midnight. Sealing it adds it straight away. Skipping the seal never breaks your run.',
            icon: Symbols.air_rounded,
          ),
          if (run > 0)
            OutlinedButton.icon(
              onPressed: () => showShareCard(
                context,
                ShareCardData(
                  headline: run == 1 ? '1 day' : '$run days',
                  caption: 'smoke-free in a row',
                  lines: [
                    if (history != null && history.bestRun > run)
                      'Best run so far: ${history.bestRun} days',
                    if (data.cigarettesAvoided > 0)
                      '${data.cigarettesAvoided} cigarettes not smoked',
                  ],
                ),
              ),
              icon: const Icon(Symbols.ios_share_rounded),
              label: const Text('Share my run'),
            ),
        ];
      },
    );
  }
}

/// The run as one number, with where it started and the best so far.
class _RunHero extends StatelessWidget {
  const _RunHero({required this.run, required this.since, required this.best});

  final int run;
  final DateTime? since;
  final int? best;

  String get _headline {
    if (run == 0) {
      return 'Today can be day one.';
    }
    if (run == 1) {
      return 'That first day is real.';
    }
    return 'In a row. Keep going.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = AppAccents.of(context);
    final color = accents.onStreakContainer;
    final since = this.since;
    final best = this.best;
    final label = run == 1 ? 'day' : 'days';

    return Semantics(
      label:
          'Smoke-free run: $run $label.'
          '${since == null ? '' : ' Since ${DateFormat.MMMMd().format(since)}.'}'
          '${best == null ? '' : ' Best run $best days.'}',
      excludeSemantics: true,
      child: AppCard(
        color: accents.streakContainer,
        child: Row(
          children: [
            Icon(Symbols.local_fire_department_rounded, size: 44, color: color),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$run',
                  style: AppTypography.displayNumber.copyWith(color: color),
                ),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headline,
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                  if (since != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Since ${DateFormat('EEE d MMM').format(since)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                  if (best != null && best > run) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Best so far: $best days',
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where today stands against the run, with the seal while the day is open.
class _Today extends StatelessWidget {
  const _Today({required this.line, required this.onSeal});

  final String line;
  final VoidCallback? onSeal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onSeal = this.onSeal;

    return AppCard(
      style: AppCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Symbols.today_rounded, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(line, style: theme.textTheme.bodyLarge)),
            ],
          ),
          if (onSeal != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onSeal,
              icon: const Icon(Symbols.verified_rounded),
              label: const Text('Seal today'),
            ),
          ],
        ],
      ),
    );
  }
}

/// The last few weeks, a mark per day. Tapping a day opens it in the journal.
class _Chain extends StatelessWidget {
  const _Chain({required this.history, required this.onDay});

  final DayHistory history;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = history.today;
    // Sunday-first weeks, to match the journal calendar.
    final weekStart = DateTime(
      today.year,
      today.month,
      today.day - today.weekday % DateTime.daysPerWeek,
    );
    final first = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day - (_chainWeeks - 1) * DateTime.daysPerWeek,
    );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your chain', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap a day to open it in the journal.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var column = 0; column < DateTime.daysPerWeek; column++)
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat.E()
                            .format(
                              DateTime(
                                first.year,
                                first.month,
                                first.day + column,
                              ),
                            )
                            .substring(0, 1),
                        style: labelStyle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var week = 0; week < _chainWeeks; week++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (var column = 0; column < DateTime.daysPerWeek; column++)
                    Expanded(
                      child: _ChainDay(
                        state: history.stateFor(
                          DateTime(
                            first.year,
                            first.month,
                            first.day + week * DateTime.daysPerWeek + column,
                          ),
                        ),
                        onTap: onDay,
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

class _ChainDay extends StatelessWidget {
  const _ChainDay({required this.state, required this.onTap});

  final DayState state;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final tappable =
        state.kind == DayKind.smokeFree || state.kind == DayKind.slipped;

    return Semantics(
      button: tappable,
      label:
          '${DateFormat.MMMMEEEEd().format(state.date)}: ${DayDot.describe(state)}',
      excludeSemantics: true,
      onTap: tappable ? () => onTap(state.date) : null,
      child: InkResponse(
        onTap: tappable ? () => onTap(state.date) : null,
        radius: 24,
        child: SizedBox(
          height: 48,
          child: Center(child: DayDot(state: state, size: 30)),
        ),
      ),
    );
  }
}

/// How far the run is from the next length worth aiming at.
class _NextTarget extends StatelessWidget {
  const _NextTarget({required this.run});

  final int run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final target = RunCalculations.nextTarget(run);
    if (target == null) {
      return const InfoCard(
        title: 'Past every target',
        body: 'Over a year in a row. There is nothing left to aim at here.',
        icon: Symbols.emoji_events_rounded,
        tone: StatTone.streak,
      );
    }
    final left = target.days - run;
    final progress = (run / target.days).clamp(0.0, 1.0);

    return AppCard(
      semanticLabel:
          '$left more ${left == 1 ? 'day' : 'days'} to a ${target.label} run.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.flag_rounded, color: accents.streak),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$left more ${left == 1 ? 'day' : 'days'} to a ${target.label} run',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: accents.streak,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$run of ${target.days} days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
