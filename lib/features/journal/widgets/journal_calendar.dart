import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/journal_calculations.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../checkin/models/seal_question.dart';
import '../../checkin/widgets/feeling_icon.dart';
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
      Symbols.check_circle_rounded,
      scheme.primary,
    ),
    JournalDayStatus.craving => _StatusStyle(
      'Craving',
      Symbols.bolt_rounded,
      accents.craving,
    ),
    JournalDayStatus.relapse => _StatusStyle(
      'Smoked',
      Symbols.circle_rounded,
      scheme.tertiary,
    ),
    JournalDayStatus.mixed => _StatusStyle(
      'Mixed',
      Symbols.contrast_rounded,
      accents.streak,
    ),
    JournalDayStatus.future || JournalDayStatus.noData => null,
  };
}

Color _feelingColor(BuildContext context, int mood) {
  final scheme = Theme.of(context).colorScheme;
  if (mood >= 4) {
    return scheme.primary;
  }
  return mood == 3 ? AppAccents.of(context).craving : scheme.tertiary;
}

/// Month grid with a lens switch, previous/next controls and a weekday header.
/// Swiping sideways also changes the month.
class JournalCalendar extends ConsumerWidget {
  const JournalCalendar({required this.data, super.key});

  final JournalData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedJournalDayProvider);
    final lens = ref.watch(journalLensProvider);
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

    void move(int months) {
      ref.read(journalMonthProvider.notifier).moveBy(months);
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          SegmentedButton<JournalLens>(
            showSelectedIcon: false,
            segments: [
              for (final option in JournalLens.values)
                ButtonSegment(value: option, label: Text(option.label)),
            ],
            selected: {lens},
            onSelectionChanged: (selection) =>
                ref.read(journalLensProvider.notifier).show(selection.first),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => move(-1),
                icon: const Icon(Symbols.chevron_left_rounded),
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
                onPressed: () => move(1),
                icon: const Icon(Symbols.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final name in weekdays)
                  Expanded(
                    child: Center(child: Text(name, style: weekdayStyle)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 200) {
                move(velocity < 0 ? 1 : -1);
              }
            },
            child: GridView.builder(
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
                return _DayCell(
                  day: day,
                  status: data.statusFor(day),
                  sealed: data.stateFor(day).sealed,
                  cravings: summary?.cravings ?? 0,
                  mood: summary?.checkIn?.mood,
                  lens: lens,
                  selected: _sameDay(day, selectedDay),
                  onTap: () =>
                      ref.read(selectedJournalDayProvider.notifier).select(day),
                );
              },
            ),
          ),
        ],
      ),
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
    required this.sealed,
    required this.cravings,
    required this.mood,
    required this.lens,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final JournalDayStatus status;
  final bool sealed;
  final int cravings;
  final int? mood;
  final JournalLens lens;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final style = _styleFor(context, status);
    final isFuture = status == JournalDayStatus.future;
    final mood = this.mood;
    final feeling = DayFeeling.labelFor(mood);
    final spoken =
        '${DateFormat.MMMMEEEEd().format(day)}. '
        '${style?.label ?? (isFuture ? 'Upcoming' : 'Before your quit date')}.'
        '${sealed ? ' Sealed.' : ''}'
        '${cravings == 0 ? '' : ' $cravings ${cravings == 1 ? 'craving' : 'cravings'}.'}'
        '${feeling == null ? '' : ' Felt ${feeling.toLowerCase()}.'}'
        '${selected ? ' Selected.' : ''}';

    final Widget? mark = switch (lens) {
      JournalLens.days =>
        style == null
            ? null
            : Icon(
                // A sealed smoke-free day gets the fuller mark.
                sealed && status == JournalDayStatus.smokeFree
                    ? Symbols.verified_rounded
                    : style.icon,
                size: 12,
                fill: sealed ? 1 : 0,
                color: style.color,
              ),
      JournalLens.cravings =>
        cravings == 0
            ? null
            : Text(
                '$cravings',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accents.craving,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
      JournalLens.mood =>
        mood == null
            ? null
            : Icon(
                feelingIcon(mood),
                size: 13,
                color: _feelingColor(context, mood),
              ),
    };

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
                  SizedBox(height: 14, child: Center(child: mark)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Explains what the calendar marks mean, in words, for the lens in use.
class JournalLegend extends StatelessWidget {
  const JournalLegend({this.lens = JournalLens.days, super.key});

  final JournalLens lens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget item(IconData icon, Color color, String label, {double fill = 0}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color, fill: fill),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: labelStyle),
        ],
      );
    }

    final List<Widget> items = switch (lens) {
      JournalLens.days => [
        for (final status in const [
          JournalDayStatus.smokeFree,
          JournalDayStatus.craving,
          JournalDayStatus.relapse,
          JournalDayStatus.mixed,
        ])
          Builder(
            builder: (context) {
              final style = _styleFor(context, status)!;
              return item(style.icon, style.color, style.label);
            },
          ),
        item(Symbols.verified_rounded, scheme.primary, 'Sealed', fill: 1),
      ],
      JournalLens.cravings => [
        Text('The number is how many cravings were logged.', style: labelStyle),
      ],
      JournalLens.mood => [
        for (final feeling in DayFeeling.all)
          item(
            feelingIcon(feeling.value),
            _feelingColor(context, feeling.value),
            feeling.label,
          ),
      ],
    };

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: items,
    );
  }
}
