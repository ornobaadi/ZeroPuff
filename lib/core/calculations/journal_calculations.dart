import 'day_history.dart';

enum JournalDayStatus { future, noData, smokeFree, craving, relapse, mixed }

class JournalCalculations {
  const JournalCalculations._();

  /// How a day reads on the calendar: what kind of day it was, and whether
  /// cravings were logged on it. Days before the quit date have nothing to
  /// say.
  static JournalDayStatus statusForDay({
    required DayKind kind,
    required int cravingCount,
  }) {
    final hadCravings = cravingCount > 0;
    return switch (kind) {
      DayKind.future => JournalDayStatus.future,
      DayKind.beforeQuit => JournalDayStatus.noData,
      DayKind.slipped =>
        hadCravings ? JournalDayStatus.mixed : JournalDayStatus.relapse,
      DayKind.smokeFree =>
        hadCravings ? JournalDayStatus.craving : JournalDayStatus.smokeFree,
    };
  }

  static List<DateTime?> monthGrid(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = first.weekday % DateTime.daysPerWeek;
    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
    ];

    while (cells.length % DateTime.daysPerWeek != 0) {
      cells.add(null);
    }

    return cells;
  }

  static DateTime dateOnly(DateTime value) => _dateOnly(value);

  static String localDateKey(DateTime value) {
    final date = _dateOnly(value);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
