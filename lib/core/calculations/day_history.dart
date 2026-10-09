import 'streak_calculations.dart';

enum DayKind { beforeQuit, smokeFree, slipped, future }

/// What one calendar day looks like in the quit.
class DayState {
  const DayState({
    required this.date,
    required this.kind,
    this.sealed = false,
    this.isToday = false,
  });

  final DateTime date;
  final DayKind kind;

  /// The day was closed with an evening seal.
  final bool sealed;
  final bool isToday;

  bool get smokeFree => kind == DayKind.smokeFree;
  bool get slipped => kind == DayKind.slipped;
}

/// Every day since the quit date, worked out from what was logged.
///
/// A day is smoke-free unless a cigarette was logged on it, so nothing has to
/// be confirmed for a run to continue. Today only joins the run once it is
/// sealed; until then the run stands at yesterday, and at midnight today
/// joins on its own.
class DayHistory {
  DayHistory({
    required DateTime quitDate,
    required DateTime today,
    Iterable<DateTime> slipDays = const [],
    Iterable<DateTime> sealedDays = const [],
  }) : quitDay = StreakCalculations.dateOnly(quitDate),
       today = StreakCalculations.dateOnly(today),
       _slips = slipDays.map(StreakCalculations.dateOnly).toSet(),
       _sealed = sealedDays.map(StreakCalculations.dateOnly).toSet();

  final DateTime quitDay;
  final DateTime today;
  final Set<DateTime> _slips;
  final Set<DateTime> _sealed;

  /// False while the quit date is still ahead.
  bool get started => !today.isBefore(quitDay);

  bool get slippedToday => _slips.contains(today);

  /// Today has been closed, whichever way it went.
  bool get sealedToday => _sealed.contains(today);

  DayState stateFor(DateTime day) {
    final date = StreakCalculations.dateOnly(day);
    final DayKind kind;
    if (date.isAfter(today)) {
      kind = DayKind.future;
    } else if (date.isBefore(quitDay)) {
      kind = DayKind.beforeQuit;
    } else if (_slips.contains(date)) {
      kind = DayKind.slipped;
    } else {
      kind = DayKind.smokeFree;
    }
    return DayState(
      date: date,
      kind: kind,
      sealed: _sealed.contains(date),
      isToday: date == today,
    );
  }

  /// Smoke-free days in a row: every clear day up to yesterday, plus today
  /// once it is sealed. A cigarette today brings it to zero.
  late final int currentRun = _currentRun();

  /// The first day of the current run, when there is one.
  DateTime? get runStart {
    if (currentRun == 0) {
      return null;
    }
    final last = _countsToday ? today : _previous(today);
    return DateTime(last.year, last.month, last.day - (currentRun - 1));
  }

  /// The longest run so far, including the current one.
  late final int bestRun = _bestRun();

  /// Smoke-free days in total since the quit date.
  late final int smokeFreeDays = _allDays().where(_counts).length;

  /// Days closed with a seal.
  late final int sealedCount = _sealed
      .where((day) => !day.isBefore(quitDay) && !day.isAfter(today))
      .length;

  /// The days on which a run ended: a cigarette after at least one clear day.
  late final List<DateTime> runEnds = [
    for (final day in _allDays())
      if (_slips.contains(day) &&
          !_previous(day).isBefore(quitDay) &&
          !_slips.contains(_previous(day)))
        day,
  ];

  /// The [count] days ending today, oldest first.
  List<DayState> lastDays(int count) {
    return [
      for (var back = count - 1; back >= 0; back--)
        stateFor(DateTime(today.year, today.month, today.day - back)),
    ];
  }

  bool get _countsToday => started && sealedToday && !slippedToday;

  /// Whether [day] is a smoke-free day that is already in the bank.
  bool _counts(DateTime day) {
    if (day.isBefore(quitDay) || day.isAfter(today) || _slips.contains(day)) {
      return false;
    }
    return day.isBefore(today) || sealedToday;
  }

  int _currentRun() {
    if (!started || slippedToday) {
      return 0;
    }
    var run = _countsToday ? 1 : 0;
    var cursor = _previous(today);
    while (!cursor.isBefore(quitDay) && !_slips.contains(cursor)) {
      run += 1;
      cursor = _previous(cursor);
    }
    return run;
  }

  int _bestRun() {
    var best = 0;
    var run = 0;
    for (final day in _allDays()) {
      if (_slips.contains(day)) {
        run = 0;
      } else if (_counts(day)) {
        run += 1;
        if (run > best) {
          best = run;
        }
      }
    }
    return best;
  }

  Iterable<DateTime> _allDays() sync* {
    var cursor = quitDay;
    while (!cursor.isAfter(today)) {
      yield cursor;
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
  }

  static DateTime _previous(DateTime day) =>
      StreakCalculations.previousDay(day);
}
