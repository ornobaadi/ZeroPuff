import 'package:intl/intl.dart';

import 'day_history.dart';

/// A length of smoke-free run worth aiming at.
class RunTarget {
  const RunTarget(this.days, this.label);

  final int days;

  /// How the target reads in a sentence: "a 2-week run".
  final String label;
}

class RunCalculations {
  const RunCalculations._();

  static const targets = [
    RunTarget(1, '1-day'),
    RunTarget(3, '3-day'),
    RunTarget(7, '1-week'),
    RunTarget(14, '2-week'),
    RunTarget(21, '3-week'),
    RunTarget(30, '1-month'),
    RunTarget(60, '2-month'),
    RunTarget(90, '3-month'),
    RunTarget(180, '6-month'),
    RunTarget(365, '1-year'),
  ];

  /// The next run length to aim at, or null past the last one.
  static RunTarget? nextTarget(int run) {
    for (final target in targets) {
      if (target.days > run) {
        return target;
      }
    }
    return null;
  }

  /// What today is doing to the run, in one line. Null while the quit date is
  /// still ahead.
  static String? todayLine(DayHistory history) {
    if (!history.started) {
      return null;
    }
    if (history.slippedToday) {
      return 'A cigarette is logged today. A new run can start tomorrow.';
    }
    if (history.sealedToday) {
      return 'Today is sealed and already in your run.';
    }
    return 'Today counts at midnight, or now if you seal it.';
  }

  /// A sentence about when runs have tended to end, once that has happened at
  /// least twice in the same way. [slipTimes] are the cigarettes logged, used
  /// to place each ending in the day.
  static String? runEndInsight({
    required List<DateTime> runEnds,
    required List<DateTime> slipTimes,
  }) {
    if (runEnds.length < 2) {
      return null;
    }

    final weekday = _clearMode(runEnds.map((day) => day.weekday));
    final partsOfDay = <String>[];
    for (final end in runEnds) {
      final first = slipTimes
          .where(
            (time) =>
                time.year == end.year &&
                time.month == end.month &&
                time.day == end.day,
          )
          .fold<DateTime?>(
            null,
            (earliest, time) =>
                earliest == null || time.isBefore(earliest) ? time : earliest,
          );
      if (first != null) {
        partsOfDay.add(_partOfDay(first.hour));
      }
    }
    final partOfDay = _clearMode(partsOfDay);

    if (weekday != null) {
      // 2024-01-01 was a Monday, so day N is weekday N.
      final name = DateFormat.EEEE().format(DateTime(2024, 1, weekday));
      return partOfDay == null
          ? 'Your runs have ended most often on ${name}s.'
          : 'Your runs have ended most often on ${name}s, usually $partOfDay.';
    }
    return partOfDay == null
        ? null
        : 'Your runs have usually ended $partOfDay.';
  }

  static String _partOfDay(int hour) {
    if (hour < 5 || hour >= 21) {
      return 'late at night';
    }
    if (hour < 12) {
      return 'in the morning';
    }
    if (hour < 17) {
      return 'in the afternoon';
    }
    return 'in the evening';
  }

  /// The value seen most, if it was seen at least twice and nothing ties it.
  static T? _clearMode<T>(Iterable<T> values) {
    final counts = <T, int>{};
    for (final value in values) {
      counts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    T? best;
    var bestCount = 1;
    var tied = false;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        best = entry.key;
        bestCount = entry.value;
        tied = false;
      } else if (entry.value == bestCount && best != null) {
        tied = true;
      }
    }
    return tied ? null : best;
  }
}

/// Round amounts of money to aim at, counted in packs so they make sense in
/// any currency.
class SavingsTargets {
  const SavingsTargets._();

  static const packs = [1, 5, 10, 20, 50, 100, 200, 500, 1000];

  /// The next number of packs' worth to reach, or null when there is no pack
  /// price or every target has been passed.
  static ({double amount, int packs})? next({
    required double saved,
    required double packPrice,
  }) {
    if (packPrice <= 0) {
      return null;
    }
    for (final count in packs) {
      final amount = count * packPrice;
      if (saved < amount) {
        return (amount: amount, packs: count);
      }
    }
    return null;
  }
}
