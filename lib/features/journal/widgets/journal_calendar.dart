import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/calculations/journal_calculations.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/journal_providers.dart';

/// Icon + color + words for one calendar status, so meaning never depends on
/// color alone.
class _StatusStyle {
  const _StatusStyle(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

_StatusStyle? _styleFor(BuildContext context, JournalDayStatus status) {
  final scheme = Theme.of(context).colorScheme;
  final accents = AppAccents.of(context);
  return switch (status) {
    JournalDayStatus.smokeFree => _StatusStyle(
      'Smoke-free',
      Icons.check_circle_rounded,
      scheme.primary,
    ),
    JournalDayStatus.craving => _StatusStyle(
      'Craving',
      Icons.bolt_rounded,
      accents.craving,
    ),
    JournalDayStatus.relapse => _StatusStyle(
      'Smoked',
      Icons.circle,
      scheme.tertiary,
    ),
    JournalDayStatus.mixed => _StatusStyle(
      'Mixed',
      Icons.contrast_rounded,
      accents.streak,
    ),
    JournalDayStatus.future || JournalDayStatus.noData => null,
  };
}

/// Month grid with previous/next controls, weekday header, and a legend.
class JournalCalendar extends ConsumerWidget {
  const JournalCalendar({required this.data, super.key});

  final JournalData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedJournalDayProvider);
    final cells = JournalCalculations.monthGrid(data.month);
    final weekdayStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // Locale-aware short weekday names, Sunday first to match the grid
    // (2023-01-01 was a Sunday).
    final weekdays = [
      for (var i = 0; i < DateTime.daysPerWeek; i++)
        DateFormat.E().format(DateTime(2023, 1, 1 + i)),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () =>
                    ref.read(journalMonthProvider.notifier).moveBy(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    DateFormat('MMMM yyyy').format(data.month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () =>
                    ref.read(journalMonthProvider.notifier).moveBy(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final name in weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        name,
                        style: weekdayStyle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            itemCount: cells.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DateTime.daysPerWeek,
              mainAxisSpacing: AppSpacing.xs,
              childAspectRatio: 0.9,
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
                onTap: () =>
                    ref.read(selectedJournalDayProvider.notifier).select(day),
              );
            },
          ),
        ],
      ),
    );
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
    final scheme = theme.colorScheme;
    final style = _styleFor(context, status);
    final isFuture = status == JournalDayStatus.future;
    final spoken =
        '${DateFormat.MMMMEEEEd().format(day)}. '
        '${style?.label ?? (isFuture ? 'Upcoming' : 'No entries')}.'
        '${checkedIn ? ' Checked in.' : ''}'
        '${selected ? ' Selected.' : ''}';

    return Semantics(
      label: spoken,
      button: !isFuture,
      selected: selected,
      excludeSemantics: true,
      onTap: isFuture ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppShapes.medium,
            side: selected
                ? BorderSide(color: scheme.primary, width: 2)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.short),
            child: InkWell(
              onTap: isFuture ? null : onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isFuture
                          ? scheme.onSurfaceVariant
                          : selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    child: style == null
                        ? null
                        : Icon(style.icon, size: 12, color: style.color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Explains the calendar icons in words.
class JournalLegend extends StatelessWidget {
  const JournalLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final status in const [
          JournalDayStatus.smokeFree,
          JournalDayStatus.craving,
          JournalDayStatus.relapse,
          JournalDayStatus.mixed,
        ])
          Builder(
            builder: (context) {
              final style = _styleFor(context, status)!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(style.icon, size: 14, color: style.color),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    style.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
