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
    return consecutiveDayStreak(today: today, activeDates: checkInDates);
  }

  static int consecutiveDayStreak({
    required DateTime today,
    required Set<DateTime> activeDates,
  }) {
    if (activeDates.isEmpty) {
      return 0;
    }

    final normalizedDates = activeDates.map(dateOnly).toSet();
    var cursor = dateOnly(today);
    var streak = 0;

    while (normalizedDates.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int smokeFreeCalendarStreakDays({
    required DateTime quitDate,
    required DateTime today,
    required Set<DateTime> smokingDates,
  }) {
    final startDate = dateOnly(quitDate);
    var cursor = dateOnly(today);

    if (cursor.isBefore(startDate)) {
      return 0;
    }

    final normalizedSmokingDates = smokingDates.map(dateOnly).toSet();
    var streak = 0;

    while (!cursor.isBefore(startDate)) {
      if (normalizedSmokingDates.contains(cursor)) {
        break;
      }
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int smokeFreeCheckInStreakDays({
    required DateTime quitDate,
    required DateTime today,
    required Set<DateTime> checkInDates,
    required Set<DateTime> smokeFreeCheckInDates,
    required Set<DateTime> smokingDates,
    bool allowTodayPending = true,
  }) {
    final startDate = dateOnly(quitDate);
    final todayDate = dateOnly(today);
    if (todayDate.isBefore(startDate)) {
      return 0;
    }

    final normalizedCheckIns = checkInDates.map(dateOnly).toSet();
    final normalizedSmokeFreeCheckIns = smokeFreeCheckInDates
        .map(dateOnly)
        .toSet();
    final normalizedSmokingDates = smokingDates.map(dateOnly).toSet();

    if (normalizedSmokingDates.contains(todayDate)) {
      return 0;
    }

    var cursor = todayDate;
    var streak = 0;
    final checkedInToday = normalizedCheckIns.contains(todayDate);
    final smokeFreeToday = normalizedSmokeFreeCheckIns.contains(todayDate);

    if (smokeFreeToday) {
      streak = 1;
      cursor = cursor.subtract(const Duration(days: 1));
    } else if (checkedInToday) {
      return 0;
    } else if (allowTodayPending) {
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    while (!cursor.isBefore(startDate)) {
      if (normalizedSmokingDates.contains(cursor)) {
        break;
      }
      if (!normalizedSmokeFreeCheckIns.contains(cursor)) {
        break;
      }
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int honestyStreakDaysFromActivity({
    required DateTime today,
    required Set<DateTime> checkInDates,
    required Set<DateTime> smokingLogDates,
  }) {
    return consecutiveDayStreak(
      today: today,
      activeDates: {...checkInDates, ...smokingLogDates},
    );
  }

  static int resistanceStreak(List<String> outcomesNewestFirst) {
    var streak = 0;
    for (final outcome in outcomesNewestFirst) {
      if (outcome == 'unknown') {
        continue;
      }
      if (outcome != 'resisted') {
        break;
      }
      streak += 1;
    }
    return streak;
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime? parseLocalDateKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static int legacyHonestyStreakDays({
    required DateTime today,
    required Set<DateTime> checkInDates,
  }) {
    if (checkInDates.isEmpty) {
      return 0;
    }

    final normalizedDates = checkInDates.map(dateOnly).toSet();
    var cursor = dateOnly(today);
    var streak = 0;

    while (normalizedDates.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
