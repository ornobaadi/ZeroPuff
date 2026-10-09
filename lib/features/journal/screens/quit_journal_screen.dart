import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../../models/craving_rescue_data.dart';
import '../../checkin/models/seal_question.dart';
import '../../logging/widgets/slip_form.dart';
import '../../rescue/models/rescue_tool.dart';
import '../../stats/widgets/detail_widgets.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_calendar.dart';
import '../widgets/month_insights.dart';

class QuitJournalScreen extends ConsumerWidget {
  const QuitJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalDataProvider);
    final lens = ref.watch(journalLensProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: SafeArea(
        bottom: false,
        child: journal.when(
          loading: () => const StateView.loading(label: 'Loading journal'),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(journalDataProvider),
          ),
          data: (data) => ListView(
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
                      'Every day since you quit, filled in for you. Tap a day to see what happened.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _JournalStats(data: data),
                    const SizedBox(height: AppSpacing.lg),
                    JournalCalendar(data: data),
                    const SizedBox(height: AppSpacing.md),
                    JournalLegend(lens: lens),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _SelectedDayDetails(data: data),
                    const SizedBox(height: AppSpacing.sectionGap),
                    MonthInsightsCard(
                      month: data.month,
                      insights: data.insights,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The month in four numbers.
class _JournalStats extends StatelessWidget {
  const _JournalStats({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context) {
    final winRate = data.winRate;

    return Column(
      children: [
        EvenRow(
          children: [
            MiniStat(
              value: '${data.smokeFreeDays}',
              label: 'smoke-free days',
              tone: StatTone.streak,
            ),
            MiniStat(
              value: '${data.cravingsBeaten}',
              label: 'cravings beaten',
              tone: StatTone.craving,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        EvenRow(
          children: [
            MiniStat(value: '${data.cigarettes}', label: 'cigarettes'),
            MiniStat(
              value: winRate == null ? '–' : '${(winRate * 100).round()}%',
              label: 'cravings won',
              tone: StatTone.money,
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectedDayDetails extends ConsumerWidget {
  const _SelectedDayDetails({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedJournalDayProvider);
    final summary = data.summaryFor(selectedDay);
    final state = data.stateFor(selectedDay);
    final title = DateFormat('EEEE, MMM d').format(selectedDay);
    final canLog =
        state.kind == DayKind.smokeFree || state.kind == DayKind.slipped;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                liveRegion: true,
                child: Text(title, style: theme.textTheme.titleLarge),
              ),
            ),
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                ref.read(journalMonthProvider.notifier).show(now);
                ref.read(selectedJournalDayProvider.notifier).select(now);
              },
              child: const Text('Today'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _story(state, summary),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (summary != null && summary.hasEntries) ...[
          const SizedBox(height: AppSpacing.md),
          _EntryTimeline(summary: summary),
        ],
        if (canLog) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (state.isToday && !state.sealed)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => context.push(AppRoutes.checkIn),
                  icon: const Icon(Symbols.verified_rounded),
                  label: const Text('Seal today'),
                ),
              TextButton.icon(
                onPressed: () => showSlipSheet(
                  context,
                  // Today is logged as now; an earlier day keeps its date.
                  day: state.isToday ? null : selectedDay,
                ),
                icon: const Icon(Symbols.edit_note_rounded),
                label: Text(
                  state.isToday ? 'Log a slip' : 'Add a slip for this day',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// The day in a sentence or two.
  String _story(DayState state, JournalDaySummary? summary) {
    final beaten =
        summary?.cravingsList.where((craving) => craving.resisted).length ?? 0;
    final seal = summary?.checkIn;

    final String opening;
    switch (state.kind) {
      case DayKind.future:
        return 'Still ahead.';
      case DayKind.beforeQuit:
        return 'Before your quit date.';
      case DayKind.slipped:
        final count = [
          summary?.smokes ?? 0,
          seal?.cigarettesSmoked ?? 0,
        ].reduce((a, b) => a > b ? a : b);
        opening = count <= 1
            ? 'A cigarette was logged.'
            : '$count cigarettes were logged.';
      case DayKind.smokeFree:
        opening = state.sealed
            ? 'Smoke-free and sealed.'
            : state.isToday
            ? 'Smoke-free so far.'
            : 'Smoke-free.';
    }

    final feeling = DayFeeling.labelFor(seal?.mood);
    final tags = seal?.tags ?? const [];
    final helpful = tags.where(SealQuestion.helpfulValues.contains).toList();
    final hard = tags
        .where((tag) => !SealQuestion.helpfulValues.contains(tag))
        .toList();
    String list(List<String> values) => values
        .map((tag) => SealQuestion.labelFor(tag).toLowerCase())
        .join(', ');

    return [
      opening,
      if (beaten == 1) '1 craving beaten.',
      if (beaten > 1) '$beaten cravings beaten.',
      if (feeling != null) 'Felt ${feeling.toLowerCase()}.',
      if (helpful.isNotEmpty) 'What helped: ${list(helpful)}.',
      if (hard.isNotEmpty) 'What made it hard: ${list(hard)}.',
    ].join(' ');
  }
}

class _EntryTimeline extends StatelessWidget {
  const _EntryTimeline({required this.summary});

  final JournalDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accents = AppAccents.of(context);
    final entries = <Widget>[];

    for (final craving in summary.cravingsList.reversed) {
      entries.add(
        _TimelineEntry(
          icon: craving.resisted
              ? Symbols.check_circle_rounded
              : Symbols.bolt_rounded,
          color: accents.craving,
          title: _cravingTitle(craving),
          subtitle: _cravingDetail(craving),
        ),
      );
    }
    for (final log in summary.smokingLogs.reversed) {
      entries.add(
        _TimelineEntry(
          icon: Symbols.edit_note_rounded,
          color: scheme.tertiary,
          title: '${log.count} cigarette${log.count == 1 ? '' : 's'} logged',
          subtitle: [
            _time(log.smokedAt),
            slipTriggers[log.trigger] ?? log.trigger,
            if (log.note != null) log.note!,
          ].join(' · '),
          onEdit: () => context.push('${AppRoutes.logging}?logId=${log.logId}'),
        ),
      );
    }
    final seal = summary.checkIn;
    if (seal != null) {
      final note = seal.note;
      entries.add(
        _TimelineEntry(
          icon: Symbols.verified_rounded,
          color: scheme.primary,
          title: seal.smokeFreeToday ? 'Day sealed' : 'Day closed',
          subtitle: note == null || note.isEmpty
              ? 'Closed at ${_time(seal.createdAt)}'
              : note,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          entries[i],
        ],
      ],
    );
  }

  String _cravingTitle(CravingRescueData craving) {
    return switch (craving.outcome) {
      'resisted' => 'Craving beaten',
      'smoked' => 'Craving, then a cigarette',
      'still_craving' => 'Craving, still strong',
      'abandoned' => 'Craving, left early',
      _ => 'Craving',
    };
  }

  /// Time, how the urge moved, what was used and what set it off.
  String _cravingDetail(CravingRescueData craving) {
    final after = craving.intensityAfter;
    return [
      _time(craving.startedAt),
      after == null || after == craving.intensity
          ? 'urge ${craving.intensity} of 10'
          : 'urge ${craving.intensity} to $after',
      if (craving.toolsUsed.isNotEmpty)
        craving.toolsUsed
            .map((id) => rescueToolById(id).title.toLowerCase())
            .join(', '),
      if (craving.triggers.isNotEmpty) craving.triggers.join(', '),
    ].join(' · ');
  }

  String _time(DateTime value) => DateFormat.jm().format(value);
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onEdit,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit log',
              onPressed: onEdit,
              icon: const Icon(Symbols.edit_rounded),
            ),
        ],
      ),
    );
  }
}
