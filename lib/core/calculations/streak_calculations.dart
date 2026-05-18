class StreakCalculations {
  const StreakCalculations._();

  static int smokeFreeDays({
    required DateTime quitDate,
    required DateTime now,
  }) {
    if (now.isBefore(quitDate)) {
      return 0;
    }
    return now.difference(quitDate).inDays;
  }

  static int honestyStreakDays({
    required DateTime today,
    required Set<DateTime> checkInDates,
  }) {
    if (checkInDates.isEmpty) {
      return 0;
    }

    final normalizedDates = checkInDates.map(_dateOnly).toSet();
    var cursor = _dateOnly(today);
    var streak = 0;

    while (normalizedDates.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
