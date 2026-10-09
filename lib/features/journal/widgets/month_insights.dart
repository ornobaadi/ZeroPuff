import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/journal_insights.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../checkin/models/seal_question.dart';

/// What the month's cravings add up to: which days and times are hardest,
/// what sets them off and what helps.
class MonthInsightsCard extends StatelessWidget {
  const MonthInsightsCard({
    required this.month,
    required this.insights,
    super.key,
  });

  final DateTime month;
  final MonthInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = 'Patterns in ${DateFormat.MMMM().format(month)}';

    if (!insights.hasCravings) {
      return AppCard(
        style: AppCardStyle.outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              insights.topHelpfulTag == null
                  ? 'No cravings logged this month. When there are, they show up here by weekday and time of day.'
                  : 'No cravings logged this month. What has helped most: ${SealQuestion.labelFor(insights.topHelpfulTag!).toLowerCase()}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final hardestDay = insights.hardestWeekday;
    // 2024-01-01 was a Monday, so day N is weekday N.
    final hardestDayName = hardestDay == null
        ? null
        : DateFormat.EEEE().format(DateTime(2024, 1, hardestDay));
    final hardestPart = insights.hardestPartOfDay;
    final trigger = insights.topTrigger;
    final helped = insights.topHelpfulTag;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            hardestDayName == null
                ? 'By day of the week'
                : '${hardestDayName}s are your hardest day',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Bars(
            values: insights.byWeekday,
            // Sunday first, to match the calendar above.
            labels: [
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                DateFormat.E().format(DateTime(2023, 1, 1 + i)).substring(0, 1),
            ],
            spoken: [
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                DateFormat.EEEE().format(DateTime(2023, 1, 1 + i)),
            ],
            highlight: hardestDay == null
                ? null
                : hardestDay % DateTime.daysPerWeek,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hardestPart == null
                ? 'By time of day'
                : 'Mostly in the ${hardestPart.label.toLowerCase()}',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Bars(
            values: insights.byPartOfDay,
            labels: [for (final part in PartOfDay.values) part.label],
            spoken: [for (final part in PartOfDay.values) part.label],
            highlight: hardestPart?.index,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (trigger != null)
            _InsightLine(
              icon: Symbols.bolt_rounded,
              text:
                  'Set off most by: ${trigger[0].toUpperCase()}${trigger.substring(1)}',
            ),
          if (helped != null)
            _InsightLine(
              icon: Symbols.favorite_rounded,
              text: 'What helps most: ${SealQuestion.labelFor(helped)}',
            ),
          _InsightLine(
            icon: Symbols.trending_flat_rounded,
            text: _comparison(insights),
          ),
        ],
      ),
    );
  }

  String _comparison(MonthInsights insights) {
    final now = insights.cravings;
    final before = insights.cravingsLastMonth;
    final count = '$now ${now == 1 ? 'craving' : 'cravings'} logged';
    if (before == 0) {
      return '$count this month.';
    }
    if (now < before) {
      return '$count, down from $before last month.';
    }
    if (now > before) {
      return '$count, up from $before last month.';
    }
    return '$count, the same as last month.';
  }
}

/// Plain bars: no axes, the tallest one picked out.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.values,
    required this.labels,
    required this.spoken,
    required this.highlight,
  });

  static const _height = 56.0;

  final List<int> values;
  final List<String> labels;
  final List<String> spoken;
  final int? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final most = values.fold<int>(0, (a, b) => a > b ? a : b);

    return Semantics(
      label: [
        for (var i = 0; i < values.length; i++) '${spoken[i]}: ${values[i]}',
      ].join(', '),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        values[i] == 0 ? '' : '${values[i]}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: i == highlight
                              ? accents.craving
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        // A sliver even at zero, so the row reads as a chart.
                        height: most == 0
                            ? 4
                            : 4 + (_height - 4) * values[i] / most,
                        decoration: BoxDecoration(
                          color: i == highlight
                              ? accents.craving
                              : values[i] == 0
                              ? scheme.surfaceContainerHighest
                              : accents.cravingContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
