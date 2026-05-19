enum JournalDayStatus { future, noData, smokeFree, craving, relapse, mixed }

class JournalCalculations {
  const JournalCalculations._();

  static JournalDayStatus statusForDay({
    required DateTime day,
    required DateTime today,
    required bool hasCheckIn,
    required bool smokeFreeCheckIn,
    required int checkInCigarettes,
    required int smokingLogCount,
    required int cravingCount,
  }) {
    if (_dateOnly(day).isAfter(_dateOnly(today))) {
      return JournalDayStatus.future;
    }

    final hasRelapse = smokingLogCount > 0 || checkInCigarettes > 0;
    final hasCraving = cravingCount > 0;
    if (hasRelapse && hasCraving) {
      return JournalDayStatus.mixed;
    }
    if (hasRelapse) {
      return JournalDayStatus.relapse;
    }
    if (hasCraving) {
      return JournalDayStatus.craving;
    }
    if (hasCheckIn && smokeFreeCheckIn) {
      return JournalDayStatus.smokeFree;
    }
    return JournalDayStatus.noData;
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
