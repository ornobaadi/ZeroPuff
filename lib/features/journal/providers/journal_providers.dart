import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/journal_calculations.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/craving_rescue_data.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

final journalMonthProvider = NotifierProvider<JournalMonthNotifier, DateTime>(
  JournalMonthNotifier.new,
);

final selectedJournalDayProvider =
    NotifierProvider<SelectedJournalDayNotifier, DateTime>(
      SelectedJournalDayNotifier.new,
    );

final journalDataProvider = Provider<AsyncValue<JournalData>>((ref) {
  final month = ref.watch(journalMonthProvider);
  final checkIns = ref.watch(recentCheckInsProvider);
  final smokingLogs = ref.watch(recentSmokingLogsProvider);
  final cravings = ref.watch(recentCravingsProvider);
  final dashboard = ref.watch(homeDashboardProvider);

  if (checkIns is AsyncLoading ||
      smokingLogs is AsyncLoading ||
      cravings is AsyncLoading ||
      dashboard is AsyncLoading) {
    return const AsyncLoading<JournalData>();
  }
  if (checkIns is AsyncError) {
    return AsyncError<JournalData>(checkIns.error!, checkIns.stackTrace!);
  }
  if (smokingLogs is AsyncError) {
    return AsyncError<JournalData>(smokingLogs.error!, smokingLogs.stackTrace!);
  }
  if (cravings is AsyncError) {
    return AsyncError<JournalData>(cravings.error!, cravings.stackTrace!);
  }
  if (dashboard is AsyncError) {
    return AsyncError<JournalData>(dashboard.error!, dashboard.stackTrace!);
  }

  final today = DateTime.now();
  final checkInRows = checkIns.value ?? const [];
  final smokingRows = smokingLogs.value ?? const [];
  final cravingRows = cravings.value ?? const [];
  final daySummaries = <String, JournalDaySummary>{};

  JournalDaySummary ensureSummary(DateTime date) {
    final key = JournalCalculations.localDateKey(date);
    return daySummaries.putIfAbsent(
      key,
      () => JournalDaySummary(date: JournalCalculations.dateOnly(date)),
    );
  }

  for (final checkIn in checkInRows) {
    final date = DateTime.tryParse(checkIn.localDate);
    if (date == null) {
      continue;
    }
    final summary = ensureSummary(date);
    summary
      ..hasCheckIn = true
      ..smokeFreeCheckIn = checkIn.smokeFreeToday
      ..checkInCigarettes = checkIn.cigarettesSmoked
      ..entries += 1
      ..checkIn = checkIn;
  }

  for (final log in smokingRows) {
    final summary = ensureSummary(log.smokedAt);
    summary
      ..smokes += log.count
      ..entries += 1
      ..smokingLogs.add(log);
  }

  for (final craving in cravingRows) {
    final summary = ensureSummary(craving.startedAt);
    summary
      ..cravings += 1
      ..entries += 1
      ..intensityTotal += craving.intensity
      ..cravingsList.add(craving);
  }

  for (final summary in daySummaries.values) {
    summary.status = JournalCalculations.statusForDay(
      day: summary.date,
      today: today,
      hasCheckIn: summary.hasCheckIn,
      smokeFreeCheckIn: summary.smokeFreeCheckIn,
      checkInCigarettes: summary.checkInCigarettes,
      smokingLogCount: summary.smokes,
      cravingCount: summary.cravings,
    );
  }

  final monthKeys = JournalCalculations.monthGrid(
    month,
  ).whereType<DateTime>().map(JournalCalculations.localDateKey).toSet();
  final monthSummaries = daySummaries.entries
      .where((entry) => monthKeys.contains(entry.key))
      .map((entry) => entry.value)
      .toList();
  final trackedDays = monthSummaries
      .where((summary) => summary.status != JournalDayStatus.noData)
      .length;
  final smokeFreeDays = monthSummaries
      .where((summary) => summary.status == JournalDayStatus.smokeFree)
      .length;
  final successRate = trackedDays == 0 ? 0.0 : smokeFreeDays / trackedDays;

  return AsyncData(
    JournalData(
      month: month,
      summariesByKey: daySummaries,
      smokeFreeStreak: dashboard.value?.smokeFreeStreakDays ?? 0,
      totalTrackedDays: trackedDays,
      smokeFreeDays: smokeFreeDays,
      successRate: successRate,
    ),
  );
});

class JournalData {
  const JournalData({
    required this.month,
    required this.summariesByKey,
    required this.smokeFreeStreak,
    required this.totalTrackedDays,
    required this.smokeFreeDays,
    required this.successRate,
  });

  final DateTime month;
  final Map<String, JournalDaySummary> summariesByKey;
  final int smokeFreeStreak;
  final int totalTrackedDays;
  final int smokeFreeDays;
  final double successRate;

  JournalDaySummary? summaryFor(DateTime day) {
    return summariesByKey[JournalCalculations.localDateKey(day)];
  }
}

class JournalMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void moveBy(int monthOffset) {
    state = DateTime(state.year, state.month + monthOffset);
  }
}

class SelectedJournalDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime day) {
    state = JournalCalculations.dateOnly(day);
  }
}

class JournalDaySummary {
  JournalDaySummary({required this.date});

  final DateTime date;
  bool hasCheckIn = false;
  bool smokeFreeCheckIn = false;
  int checkInCigarettes = 0;
  int smokes = 0;
  int cravings = 0;
  int entries = 0;
  int intensityTotal = 0;
  JournalDayStatus status = JournalDayStatus.noData;
  DailyCheckInRecord? checkIn;
  final List<SmokingLogRecord> smokingLogs = [];
  final List<CravingRescueData> cravingsList = [];

  double get averageIntensity {
    if (cravings == 0) {
      return 0;
    }
    return intensityTotal / cravings;
  }
}
