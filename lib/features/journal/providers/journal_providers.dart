import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/journal_calculations.dart';
import '../../../core/calculations/journal_insights.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/craving_rescue_data.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/smoking_log_repository.dart';
import '../../checkin/models/seal_question.dart';

/// What the calendar cells show.
enum JournalLens {
  days('Days'),
  cravings('Cravings'),
  mood('Mood');

  const JournalLens(this.label);

  final String label;
}

final journalMonthProvider = NotifierProvider<JournalMonthNotifier, DateTime>(
  JournalMonthNotifier.new,
);

final selectedJournalDayProvider =
    NotifierProvider<SelectedJournalDayNotifier, DateTime>(
      SelectedJournalDayNotifier.new,
    );

final journalLensProvider = NotifierProvider<JournalLensNotifier, JournalLens>(
  JournalLensNotifier.new,
);

final journalDataProvider = Provider<AsyncValue<JournalData>>((ref) {
  final month = ref.watch(journalMonthProvider);
  final checkIns = ref.watch(recentCheckInsProvider);
  final smokingLogs = ref.watch(recentSmokingLogsProvider);
  final cravings = ref.watch(recentCravingsProvider);
  final dashboard = ref.watch(homeDashboardProvider);
  final history = ref.watch(dayHistoryProvider);

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

  final checkInRows = checkIns.value ?? const <DailyCheckInRecord>[];
  final smokingRows = smokingLogs.value ?? const <SmokingLogRecord>[];
  final cravingRows = cravings.value ?? const <CravingRescueData>[];
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
    ensureSummary(date).checkIn = checkIn;
  }
  for (final log in smokingRows) {
    final summary = ensureSummary(log.smokedAt);
    summary
      ..smokes += log.count
      ..smokingLogs.add(log);
  }
  for (final craving in cravingRows) {
    final summary = ensureSummary(craving.startedAt);
    summary
      ..cravings += 1
      ..cravingsList.add(craving);
  }

  final data = JournalData(
    month: month,
    summariesByKey: daySummaries,
    history: history,
    today: DateTime.now(),
    insights: MonthInsights.forMonth(
      month: month,
      cravings: cravingRows,
      checkIns: checkInRows,
      helpfulTags: SealQuestion.helpfulValues,
    ),
  );
  return AsyncData(data);
});

/// Everything the journal shows for the month on screen.
class JournalData {
  JournalData({
    required this.month,
    required this.summariesByKey,
    required this.history,
    required this.today,
    required this.insights,
  });

  final DateTime month;
  final Map<String, JournalDaySummary> summariesByKey;

  /// Null only while the quit date is still loading.
  final DayHistory? history;
  final DateTime today;
  final MonthInsights insights;

  JournalDaySummary? summaryFor(DateTime day) {
    return summariesByKey[JournalCalculations.localDateKey(day)];
  }

  /// What kind of day it was. Every day since the quit date is filled in:
  /// smoke-free unless a cigarette was logged.
  DayState stateFor(DateTime day) {
    final known = history?.stateFor(day);
    if (known != null) {
      return known;
    }
    final date = JournalCalculations.dateOnly(day);
    final now = JournalCalculations.dateOnly(today);
    final summary = summaryFor(day);
    return DayState(
      date: date,
      kind: date.isAfter(now)
          ? DayKind.future
          : (summary?.smokes ?? 0) > 0
          ? DayKind.slipped
          : DayKind.beforeQuit,
      sealed: summary?.checkIn != null,
      isToday: date == now,
    );
  }

  JournalDayStatus statusFor(DateTime day) {
    return JournalCalculations.statusForDay(
      kind: stateFor(day).kind,
      cravingCount: summaryFor(day)?.cravings ?? 0,
    );
  }

  Iterable<DateTime> get _daysSoFar sync* {
    final last = DateTime(month.year, month.month + 1, 0).day;
    final now = JournalCalculations.dateOnly(today);
    for (var day = 1; day <= last; day++) {
      final date = DateTime(month.year, month.month, day);
      if (date.isAfter(now)) {
        return;
      }
      yield date;
    }
  }

  /// Smoke-free days this month that are already in the bank.
  late final int smokeFreeDays = _daysSoFar.where((day) {
    final state = stateFor(day);
    return state.smokeFree && (!state.isToday || state.sealed);
  }).length;

  late final int cravingsBeaten = _monthCravings
      .where((craving) => craving.resisted)
      .length;

  late final int cigarettes = _daysSoFar.fold(0, (sum, day) {
    final summary = summaryFor(day);
    return sum +
        math.max(summary?.smokes ?? 0, summary?.checkIn?.cigarettesSmoked ?? 0);
  });

  /// The share of finished cravings that were beaten, or null with none.
  late final double? winRate = () {
    final finished = _monthCravings
        .where((craving) => craving.outcome != 'unknown')
        .length;
    return finished == 0 ? null : cravingsBeaten / finished;
  }();

  Iterable<CravingRescueData> get _monthCravings sync* {
    for (final day in _daysSoFar) {
      yield* summaryFor(day)?.cravingsList ?? const [];
    }
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

  /// Shows the month [day] falls in.
  void show(DateTime day) {
    state = DateTime(day.year, day.month);
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

class JournalLensNotifier extends Notifier<JournalLens> {
  @override
  JournalLens build() => JournalLens.days;

  void show(JournalLens lens) => state = lens;
}

/// What was logged on one day.
class JournalDaySummary {
  JournalDaySummary({required this.date});

  final DateTime date;
  int smokes = 0;
  int cravings = 0;

  /// The day's seal, when it was closed.
  DailyCheckInRecord? checkIn;
  final List<SmokingLogRecord> smokingLogs = [];
  final List<CravingRescueData> cravingsList = [];

  bool get hasEntries =>
      checkIn != null || smokingLogs.isNotEmpty || cravingsList.isNotEmpty;
}
