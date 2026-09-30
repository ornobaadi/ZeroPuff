import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../stats/widgets/detail_widgets.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_calendar.dart';

class QuitJournalScreen extends ConsumerWidget {
  const QuitJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: SafeArea(
        child: journal.when(
          loading: () => const StateView.loading(label: 'Loading journal'),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(journalDataProvider),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A calm month-by-month view of smoke-free days, cravings and honest logs.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _JournalStats(data: data),
                    const SizedBox(height: AppSpacing.lg),
                    JournalCalendar(data: data),
                    const SizedBox(height: AppSpacing.md),
                    const JournalLegend(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _SelectedDayDetails(data: data),
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

class _JournalStats extends StatelessWidget {
  const _JournalStats({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EvenRow(
          children: [
            MiniStat(
              value: '${data.smokeFreeStreak}',
              label: 'day streak',
              tone: StatTone.streak,
            ),
            MiniStat(value: '${data.smokeFreeDays}', label: 'smoke-free days'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        EvenRow(
          children: [
            MiniStat(
              value: '${data.totalTrackedDays}',
              label: 'days tracked',
              tone: StatTone.craving,
            ),
            MiniStat(
              value: '${(data.successRate * 100).round()}%',
              label: 'smoke-free rate',
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
    final title = DateFormat('EEEE, MMM d').format(selectedDay);

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
              onPressed: () => ref
                  .read(selectedJournalDayProvider.notifier)
                  .select(DateTime.now()),
              child: const Text('Today'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        EvenRow(
          children: [
            MiniStat(
              value: '${summary?.smokes ?? 0}',
              label: 'Smoked',
              tone: StatTone.streak,
            ),
            MiniStat(
              value: '${summary?.cravings ?? 0}',
              label: 'Cravings',
              tone: StatTone.craving,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        EvenRow(
          children: [
            MiniStat(value: '${summary?.entries ?? 0}', label: 'Entries'),
            MiniStat(
              value: summary == null || summary.averageIntensity == 0
                  ? '–'
                  : '${summary.averageIntensity.toStringAsFixed(1)}/10',
              label: 'Avg intensity',
              tone: StatTone.money,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (summary == null || summary.entries == 0)
          _EmptyDayCard(day: selectedDay)
        else
          _EntryTimeline(summary: summary),
        if ((summary?.smokes ?? 0) > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          const InfoCard(
            title: 'Logged honestly',
            body:
                'Edit the log if the details need a correction; the map only gets clearer.',
            icon: Icons.favorite_rounded,
            tone: StatTone.streak,
          ),
        ],
      ],
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Nothing logged',
      body: day.isAfter(DateTime.now())
          ? 'Future days will fill in as you log.'
          : 'Add a check-in or log if something happened.',
      icon: Icons.edit_calendar_rounded,
    );
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

    final checkIn = summary.checkIn;
    if (checkIn != null) {
      entries.add(
        _TimelineEntry(
          icon: Icons.fact_check_rounded,
          color: scheme.primary,
          title: checkIn.smokeFreeToday
              ? 'Daily check-in: smoke-free'
              : 'Daily check-in: ${checkIn.cigarettesSmoked} smoked',
          subtitle: checkIn.note ?? 'How it felt: ${checkIn.mood} of 5',
        ),
      );
    }
    for (final craving in summary.cravingsList) {
      entries.add(
        _TimelineEntry(
          icon: Icons.bolt_rounded,
          color: accents.craving,
          title:
              'Craving ${craving.outcome.replaceAll('_', ' ')}',
          subtitle:
              '${_time(craving.startedAt)} · intensity ${craving.intensity} of 10',
        ),
      );
    }
    for (final log in summary.smokingLogs) {
      entries.add(
        _TimelineEntry(
          icon: Icons.edit_note_rounded,
          color: scheme.tertiary,
          title: '${log.count} cigarette${log.count == 1 ? '' : 's'} logged',
          subtitle:
              '${_time(log.smokedAt)} · ${toBeginningOfSentenceCase(log.trigger)}',
          onEdit: () => context.push('${AppRoutes.logging}?logId=${log.logId}'),
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
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
    );
  }
}
