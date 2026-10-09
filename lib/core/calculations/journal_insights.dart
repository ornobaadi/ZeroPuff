import '../../models/craving_rescue_data.dart';
import '../../repositories/daily_checkin_repository.dart';

/// The four parts of the day cravings are grouped into.
enum PartOfDay {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening'),
  night('Night');

  const PartOfDay(this.label);

  final String label;

  static PartOfDay of(DateTime time) {
    final hour = time.hour;
    if (hour < 5 || hour >= 21) {
      return PartOfDay.night;
    }
    if (hour < 12) {
      return PartOfDay.morning;
    }
    if (hour < 17) {
      return PartOfDay.afternoon;
    }
    return PartOfDay.evening;
  }
}

/// What one month of cravings and sealed days adds up to.
class MonthInsights {
  const MonthInsights({
    required this.cravings,
    required this.cravingsLastMonth,
    required this.byWeekday,
    required this.byPartOfDay,
    this.hardestWeekday,
    this.hardestPartOfDay,
    this.topTrigger,
    this.topHelpfulTag,
  });

  /// Fewer cravings than this in a month is too little to name a pattern.
  static const minimumForPattern = 3;

  final int cravings;
  final int cravingsLastMonth;

  /// Cravings on each weekday, Sunday first to match the calendar.
  final List<int> byWeekday;

  /// Cravings in each [PartOfDay], in that order.
  final List<int> byPartOfDay;

  /// The weekday (`DateTime.weekday`) with clearly the most cravings.
  final int? hardestWeekday;
  final PartOfDay? hardestPartOfDay;
  final String? topTrigger;

  /// The seal answer given most often for what helped.
  final String? topHelpfulTag;

  bool get hasCravings => cravings > 0;

  /// Works the month out. [helpfulTags] are the seal answers that describe
  /// something that worked, as opposed to what got in the way.
  static MonthInsights forMonth({
    required DateTime month,
    required List<CravingRescueData> cravings,
    required List<DailyCheckInRecord> checkIns,
    required Set<String> helpfulTags,
  }) {
    bool inMonth(DateTime time, DateTime of) {
      return time.year == of.year && time.month == of.month;
    }

    final previous = DateTime(month.year, month.month - 1);
    final thisMonth = cravings
        .where((craving) => inMonth(craving.startedAt, month))
        .toList();
    final lastMonth = cravings
        .where((craving) => inMonth(craving.startedAt, previous))
        .length;

    final byWeekday = List<int>.filled(DateTime.daysPerWeek, 0);
    final byPartOfDay = List<int>.filled(PartOfDay.values.length, 0);
    final triggers = <String, int>{};
    for (final craving in thisMonth) {
      byWeekday[craving.startedAt.weekday % DateTime.daysPerWeek] += 1;
      byPartOfDay[PartOfDay.of(craving.startedAt).index] += 1;
      for (final trigger in craving.triggers) {
        final name = trigger.trim().toLowerCase();
        if (name.isNotEmpty) {
          triggers.update(name, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }

    final helped = <String, int>{};
    final monthKey =
        '${month.year.toString().padLeft(4, '0')}-'
        '${month.month.toString().padLeft(2, '0')}-';
    for (final record in checkIns) {
      if (!record.localDate.startsWith(monthKey)) {
        continue;
      }
      for (final tag in record.tags) {
        if (helpfulTags.contains(tag)) {
          helped.update(tag, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }

    final enough = thisMonth.length >= minimumForPattern;
    final weekdayIndex = enough ? _clearMax(byWeekday) : null;
    final partIndex = enough ? _clearMax(byPartOfDay) : null;

    return MonthInsights(
      cravings: thisMonth.length,
      cravingsLastMonth: lastMonth,
      byWeekday: byWeekday,
      byPartOfDay: byPartOfDay,
      // Sunday is index 0 here and weekday 7 in DateTime.
      hardestWeekday: weekdayIndex == null
          ? null
          : (weekdayIndex == 0 ? DateTime.sunday : weekdayIndex),
      hardestPartOfDay: partIndex == null ? null : PartOfDay.values[partIndex],
      topTrigger: _top(triggers),
      topHelpfulTag: _top(helped),
    );
  }

  /// The index of the largest value, if it is at least two and nothing ties.
  static int? _clearMax(List<int> values) {
    int? best;
    var bestValue = 1;
    var tied = false;
    for (var index = 0; index < values.length; index++) {
      if (values[index] > bestValue) {
        best = index;
        bestValue = values[index];
        tied = false;
      } else if (values[index] == bestValue && best != null) {
        tied = true;
      }
    }
    return tied ? null : best;
  }

  /// The most counted key; ties go to the alphabetically first.
  static String? _top(Map<String, int> counts) {
    String? best;
    var bestCount = 0;
    for (final key in counts.keys.toList()..sort()) {
      if (counts[key]! > bestCount) {
        best = key;
        bestCount = counts[key]!;
      }
    }
    return best;
  }
}
