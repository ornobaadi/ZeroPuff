import '../../models/craving_rescue_data.dart';
import '../../repositories/smoking_log_repository.dart';

class CravingAnalysisCalculations {
  const CravingAnalysisCalculations._();

  static CravingAnalysisData analyze({
    required List<CravingRescueData> cravings,
    required List<SmokingLogRecord> smokingLogs,
    required DateTime now,
  }) {
    final sortedCravings = [...cravings]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final totalCravings = sortedCravings.length;
    final averageIntensity = totalCravings == 0
        ? 0.0
        : sortedCravings.fold<int>(
                0,
                (sum, craving) => sum + craving.intensity,
              ) /
              totalCravings;
    final resistedCount = sortedCravings
        .where((craving) => craving.outcome == 'resisted')
        .length;
    final completedCount = sortedCravings
        .where((craving) => craving.outcome != 'unknown')
        .length;
    final resistanceRate = completedCount == 0
        ? 0.0
        : resistedCount / completedCount;
    final topTriggers = _topTriggers(sortedCravings);
    final peakWindow = _peakWindow(sortedCravings);
    final weekStart = now.subtract(const Duration(days: 7));
    final previousWeekStart = now.subtract(const Duration(days: 14));
    final cravingsThisWeek = sortedCravings
        .where(
          (craving) =>
              !craving.startedAt.isBefore(weekStart) &&
              craving.startedAt.isBefore(now.add(const Duration(seconds: 1))),
        )
        .length;
    final cravingsLastWeek = sortedCravings
        .where(
          (craving) =>
              !craving.startedAt.isBefore(previousWeekStart) &&
              craving.startedAt.isBefore(weekStart),
        )
        .length;

    return CravingAnalysisData(
      totalCravings: totalCravings,
      averageIntensity: averageIntensity,
      resistanceRate: resistanceRate,
      cravingsThisWeek: cravingsThisWeek,
      cravingsLastWeek: cravingsLastWeek,
      smokeFreeDaysThisMonth: _smokeFreeDaysThisMonth(
        smokingLogs: smokingLogs,
        now: now,
      ),
      topTriggers: topTriggers,
      peakWindow: peakWindow,
      insights: _insights(
        totalCravings: totalCravings,
        topTriggers: topTriggers,
        peakWindow: peakWindow,
        resistanceRate: resistanceRate,
        cravingsThisWeek: cravingsThisWeek,
        cravingsLastWeek: cravingsLastWeek,
      ),
    );
  }

  static List<CravingTriggerStat> _topTriggers(
    List<CravingRescueData> cravings,
  ) {
    final counts = <String, int>{};
    for (final craving in cravings) {
      for (final trigger in craving.triggers) {
        final normalized = trigger.trim().toLowerCase();
        if (normalized.isEmpty) {
          continue;
        }
        counts.update(normalized, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    final rows =
        counts.entries
            .map((entry) => CravingTriggerStat(entry.key, entry.value))
            .toList()
          ..sort((a, b) {
            final countCompare = b.count.compareTo(a.count);
            return countCompare == 0
                ? a.trigger.compareTo(b.trigger)
                : countCompare;
          });
    return rows.take(3).toList();
  }

  static CravingTimeWindow? _peakWindow(List<CravingRescueData> cravings) {
    if (cravings.isEmpty) {
      return null;
    }
    final counts = <int, int>{};
    for (final craving in cravings) {
      final hour = craving.startedAt.hour;
      final startHour = hour == 0
          ? 23
          : hour.isEven
          ? hour - 1
          : hour;
      counts.update(startHour, (count) => count + 1, ifAbsent: () => 1);
    }
    final winner = counts.entries.reduce((a, b) {
      if (a.value != b.value) {
        return a.value > b.value ? a : b;
      }
      return a.key < b.key ? a : b;
    });
    return CravingTimeWindow(startHour: winner.key, count: winner.value);
  }

  static int _smokeFreeDaysThisMonth({
    required List<SmokingLogRecord> smokingLogs,
    required DateTime now,
  }) {
    final firstDay = DateTime(now.year, now.month);
    final daysElapsed = now.day;
    final smokedDays = smokingLogs
        .where(
          (log) =>
              !log.smokedAt.isBefore(firstDay) && !log.smokedAt.isAfter(now),
        )
        .map(
          (log) =>
              DateTime(log.smokedAt.year, log.smokedAt.month, log.smokedAt.day),
        )
        .toSet()
        .length;
    return (daysElapsed - smokedDays).clamp(0, daysElapsed);
  }

  static List<String> _insights({
    required int totalCravings,
    required List<CravingTriggerStat> topTriggers,
    required CravingTimeWindow? peakWindow,
    required double resistanceRate,
    required int cravingsThisWeek,
    required int cravingsLastWeek,
  }) {
    if (totalCravings < 3) {
      return const [
        'Log three cravings to unlock useful patterns.',
        'For now, every rescue session is still building your map.',
      ];
    }

    final insights = <String>[];
    if (topTriggers.isNotEmpty) {
      insights.add(
        '${_titleCase(topTriggers.first.trigger)} shows up most often.',
      );
    }
    if (peakWindow != null) {
      insights.add('Your hardest window is ${peakWindow.label}.');
    }
    insights.add(
      'You resisted ${(resistanceRate * 100).round()}% of completed cravings.',
    );
    if (cravingsThisWeek > cravingsLastWeek) {
      insights.add('Cravings are up from last week; keep rescue close.');
    } else if (cravingsThisWeek < cravingsLastWeek) {
      insights.add('Cravings are down from last week. That is movement.');
    } else {
      insights.add('Cravings are steady compared with last week.');
    }
    return insights;
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class CravingAnalysisData {
  const CravingAnalysisData({
    required this.totalCravings,
    required this.averageIntensity,
    required this.resistanceRate,
    required this.cravingsThisWeek,
    required this.cravingsLastWeek,
    required this.smokeFreeDaysThisMonth,
    required this.topTriggers,
    required this.peakWindow,
    required this.insights,
  });

  final int totalCravings;
  final double averageIntensity;
  final double resistanceRate;
  final int cravingsThisWeek;
  final int cravingsLastWeek;
  final int smokeFreeDaysThisMonth;
  final List<CravingTriggerStat> topTriggers;
  final CravingTimeWindow? peakWindow;
  final List<String> insights;

  bool get hasEnoughData => totalCravings >= 3;
}

class CravingTriggerStat {
  const CravingTriggerStat(this.trigger, this.count);

  final String trigger;
  final int count;
}

class CravingTimeWindow {
  const CravingTimeWindow({required this.startHour, required this.count});

  final int startHour;
  final int count;

  int get endHour => (startHour + 2) % 24;

  String get label => '${_hourLabel(startHour)}-${_hourLabel(endHour)}';

  String _hourLabel(int hour) {
    final normalized = hour % 24;
    final suffix = normalized >= 12 ? 'PM' : 'AM';
    final display = normalized == 0
        ? 12
        : normalized > 12
        ? normalized - 12
        : normalized;
    return '$display $suffix';
  }
}
