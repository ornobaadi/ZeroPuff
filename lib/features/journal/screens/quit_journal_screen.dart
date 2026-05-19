import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/calculations/journal_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/journal_providers.dart';

class QuitJournalScreen extends ConsumerWidget {
  const QuitJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final journal = ref.watch(journalDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quit Journal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: journal.when(
            data: (data) => [
              Text('Your quit journal', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A calm month-by-month view of smoke-free days, cravings, and honest logs.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _JournalStats(data: data),
              const SizedBox(height: AppSpacing.lg),
              _MonthCalendar(data: data),
              const SizedBox(height: AppSpacing.md),
              const _Legend(),
              const SizedBox(height: AppSpacing.sectionGap),
              _SelectedDayDetails(data: data),
            ],
            loading: () => [
              const SizedBox(height: 160),
              const Center(child: CircularProgressIndicator()),
            ],
            error: (error, _) => [
              Text('Journal unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
      ),
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
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            TextButton(
              onPressed: () => ref
                  .read(selectedJournalDayProvider.notifier)
                  .select(DateTime.now()),
              child: const Text('Today'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DayMetric(
                label: 'Smokes',
                value: '${summary?.smokes ?? 0}',
                color: AppColors.relapse,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DayMetric(
                label: 'Cravings',
                value: '${summary?.cravings ?? 0}',
                color: AppColors.accentCraving,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _DayMetric(
                label: 'Entries',
                value: '${summary?.entries ?? 0}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DayMetric(
                label: 'Avg intensity',
                value: summary == null || summary.averageIntensity == 0
                    ? '-'
                    : '${summary.averageIntensity.toStringAsFixed(1)}/10',
                color: AppColors.accentStreak,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (summary == null || summary.entries == 0)
          _EmptyDayCard(day: selectedDay)
        else
          _EntryTimeline(summary: summary),
        if ((summary?.smokes ?? 0) > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          const _RecoveryNoteCard(),
        ],
      ],
    );
  }
}

class _RecoveryNoteCard extends StatelessWidget {
  const _RecoveryNoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.relapse.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.relapse.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.relapse),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'This day is logged honestly. Edit the log if the details need a correction; the map only gets clearer.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayMetric extends StatelessWidget {
  const _DayMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard({required this.day});

  final DateTime day;

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
        children: [
          const Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              day.isAfter(DateTime.now())
                  ? 'Future days will fill in as you log.'
                  : 'No entries yet. Add a check-in or log if something happened.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTimeline extends StatelessWidget {
  const _EntryTimeline({required this.summary});

  final JournalDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[];
    final checkIn = summary.checkIn;
    if (checkIn != null) {
      entries.add(
        _TimelineEntry(
          icon: Icons.fact_check_rounded,
          color: AppColors.primary,
          title: checkIn.smokeFreeToday
              ? 'Daily check-in: smoke-free'
              : 'Daily check-in: ${checkIn.cigarettesSmoked} smoked',
          subtitle: checkIn.note ?? 'Mood ${checkIn.mood}/5',
        ),
      );
    }
    for (final craving in summary.cravingsList) {
      entries.add(
        _TimelineEntry(
          icon: Icons.bolt_rounded,
          color: AppColors.accentCraving,
          title: 'Craving ${craving.outcome.replaceAll('_', ' ')}',
          subtitle:
              '${_timeLabel(craving.startedAt)} · intensity ${craving.intensity}/10',
        ),
      );
    }
    for (final log in summary.smokingLogs) {
      entries.add(
        _TimelineEntry(
          icon: Icons.edit_note_rounded,
          color: AppColors.relapse,
          title: '${log.count} cigarette${log.count == 1 ? '' : 's'} logged',
          subtitle: '${_timeLabel(log.smokedAt)} · ${log.trigger}',
          onEdit: () => context.push('${AppRoutes.logging}?logId=${log.logId}'),
        ),
      );
    }

    return Column(
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: entry,
            ),
          )
          .toList(),
    );
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
        ? value.hour - 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
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

class _JournalStats extends StatelessWidget {
  const _JournalStats({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            value: '${data.smokeFreeStreak}',
            label: 'day streak',
            color: AppColors.accentStreak,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            value: '${data.totalTrackedDays}',
            label: 'tracked',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            value: '${data.smokeFreeDays}',
            label: 'clean days',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            value: '${(data.successRate * 100).round()}%',
            label: 'success',
            color: AppColors.accentMoney,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCalendar extends ConsumerWidget {
  const _MonthCalendar({required this.data});

  final JournalData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedJournalDayProvider);
    final cells = JournalCalculations.monthGrid(data.month);
    final weekdayStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _changeMonth(ref, -1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(data.month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () => _changeMonth(ref, 1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map(
                  (day) => Expanded(
                    child: Center(child: Text(day, style: weekdayStyle)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            itemCount: cells.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DateTime.daysPerWeek,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final day = cells[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              final summary = data.summaryFor(day);
              final status = summary?.status ?? _defaultStatus(day);
              return _DayCell(
                day: day,
                status: status,
                selected: _sameDay(day, selectedDay),
                checkedIn: summary?.hasCheckIn ?? false,
                onTap: () {
                  ref.read(selectedJournalDayProvider.notifier).select(day);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _changeMonth(WidgetRef ref, int offset) {
    ref.read(journalMonthProvider.notifier).moveBy(offset);
  }

  JournalDayStatus _defaultStatus(DateTime day) {
    return JournalCalculations.statusForDay(
      day: day,
      today: DateTime.now(),
      hasCheckIn: false,
      smokeFreeCheckIn: false,
      checkInCigarettes: 0,
      smokingLogCount: 0,
      cravingCount: 0,
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.selected,
    required this.checkedIn,
    required this.onTap,
  });

  final DateTime day;
  final JournalDayStatus status;
  final bool selected;
  final bool checkedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(status, theme);
    final muted =
        status == JournalDayStatus.future || status == JournalDayStatus.noData;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: status == JournalDayStatus.future ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: muted ? 0.26 : 0.5,
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected ? color : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: status == JournalDayStatus.future
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38)
                    : theme.colorScheme.onSurface.withValues(
                        alpha: muted ? 0.55 : 0.9,
                      ),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (status != JournalDayStatus.future &&
                status != JournalDayStatus.noData)
              Positioned(
                bottom: 8,
                child: Container(
                  width: checkedIn ? 14 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(JournalDayStatus status, ThemeData theme) {
    return switch (status) {
      JournalDayStatus.smokeFree => AppColors.primary,
      JournalDayStatus.craving => AppColors.accentCraving,
      JournalDayStatus.relapse => AppColors.relapse,
      JournalDayStatus.mixed => AppColors.accentStreak,
      JournalDayStatus.future => theme.colorScheme.outline,
      JournalDayStatus.noData => theme.colorScheme.outline,
    };
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: AppColors.primary, label: 'Smoke-free'),
        _LegendItem(color: AppColors.accentCraving, label: 'Craving'),
        _LegendItem(color: AppColors.relapse, label: 'Relapse'),
        _LegendItem(color: AppColors.accentStreak, label: 'Mixed'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
