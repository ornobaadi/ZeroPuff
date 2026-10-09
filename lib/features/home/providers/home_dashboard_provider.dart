import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/progress_calculations.dart';
import '../../../core/calculations/streak_calculations.dart';
import '../../../models/craving_rescue_data.dart';
import '../../../models/onboarding_data.dart';
import '../../../repositories/craving_repository.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

/// How many recent records are loaded. Enough for over a year of runs and
/// month views.
const _historyLimit = 400;

/// Refreshes the dashboard once a minute. The live seconds clock is owned by
/// the timer widget itself, so ticking every second here would needlessly
/// rebuild every screen that reads the dashboard.
final homeTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  ).startWith(DateTime.now());
});

final homeBaselineProvider = FutureProvider<OnboardingData>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  final completedProfile = await repository.loadCompletedProfile();
  if (completedProfile != null) {
    return OnboardingData(
      quitDate: completedProfile.quitDate,
      cigarettesPerDay: completedProfile.cigarettesPerDay,
      packPrice: completedProfile.packPrice,
      packSize: completedProfile.packSize,
      currencyCode: completedProfile.currencyCode,
      currencySymbol: completedProfile.currencySymbol,
      triggers: completedProfile.triggers,
      quitReason: completedProfile.quitReason,
      usualSmokingWindow: completedProfile.usualSmokingWindow,
      completed: true,
    );
  }

  final draft = await repository.loadDraft();
  return draft ??
      OnboardingData(
        quitDate: DateTime.now(),
        cigarettesPerDay: 10,
        packPrice: 12,
        packSize: 20,
        currencyCode: 'USD',
        currencySymbol: r'$',
        triggers: const ['stress'],
        completed: false,
      );
});

final homeDashboardProvider = Provider<AsyncValue<HomeDashboardData>>((ref) {
  final now = ref.watch(homeTickerProvider).value ?? DateTime.now();
  final baseline = ref.watch(homeBaselineProvider);
  final latestSmoke = ref.watch(latestSmokeAtProvider);
  final todayCheckIn = ref.watch(todayCheckInProvider);
  final recentCheckIns = ref.watch(recentCheckInsProvider);
  final recentSmokingLogs = ref.watch(recentSmokingLogsProvider);
  final recentCravings = ref.watch(recentCravingsProvider);

  if (baseline is AsyncLoading ||
      latestSmoke is AsyncLoading ||
      todayCheckIn is AsyncLoading ||
      recentCheckIns is AsyncLoading ||
      recentSmokingLogs is AsyncLoading ||
      recentCravings is AsyncLoading) {
    return const AsyncLoading<HomeDashboardData>();
  }
  if (baseline is AsyncError) {
    return AsyncError<HomeDashboardData>(baseline.error!, baseline.stackTrace!);
  }
  if (latestSmoke is AsyncError) {
    return AsyncError<HomeDashboardData>(
      latestSmoke.error!,
      latestSmoke.stackTrace!,
    );
  }
  if (todayCheckIn is AsyncError) {
    return AsyncError<HomeDashboardData>(
      todayCheckIn.error!,
      todayCheckIn.stackTrace!,
    );
  }
  if (recentCheckIns is AsyncError) {
    return AsyncError<HomeDashboardData>(
      recentCheckIns.error!,
      recentCheckIns.stackTrace!,
    );
  }
  if (recentSmokingLogs is AsyncError) {
    return AsyncError<HomeDashboardData>(
      recentSmokingLogs.error!,
      recentSmokingLogs.stackTrace!,
    );
  }
  if (recentCravings is AsyncError) {
    return AsyncError<HomeDashboardData>(
      recentCravings.error!,
      recentCravings.stackTrace!,
    );
  }

  final data = baseline.value;
  if (data == null) {
    return const AsyncLoading<HomeDashboardData>();
  }

  final loggedSmokeAt = latestSmoke.value;
  final checkIn = todayCheckIn.value;
  final checkIns = recentCheckIns.value ?? const <DailyCheckInRecord>[];
  final smokingLogs = recentSmokingLogs.value ?? const <SmokingLogRecord>[];
  final cravings = recentCravings.value ?? const <CravingRescueData>[];
  final baselineQuitDate = data.quitDate ?? now;
  final quitDate =
      loggedSmokeAt != null && loggedSmokeAt.isAfter(baselineQuitDate)
      ? loggedSmokeAt
      : baselineQuitDate;
  final smokeFreeDuration = now.isBefore(quitDate)
      ? Duration.zero
      : now.difference(quitDate);
  final cigarettesPerDay = data.cigarettesPerDay ?? 0;
  final packSize = data.packSize ?? 20;
  final packPrice = data.packPrice ?? 0;
  // Counted from the quit date, less what was actually smoked. A slip costs
  // the cigarettes smoked, not everything kept before it.
  final sinceQuit = now.isBefore(baselineQuitDate)
      ? Duration.zero
      : now.difference(baselineQuitDate);
  final smoked = _cigarettesSmoked(
    since: baselineQuitDate,
    now: now,
    checkIns: checkIns,
    smokingLogs: smokingLogs,
  );
  final cigarettesAvoided = math.max(
    0,
    ProgressCalculations.cigarettesAvoided(
          smokeFreeDuration: sinceQuit,
          cigarettesPerDay: cigarettesPerDay,
        ) -
        smoked.total,
  );
  final startOfToday = StreakCalculations.dateOnly(now);
  final todayFrom = baselineQuitDate.isAfter(startOfToday)
      ? baselineQuitDate
      : startOfToday;
  final todayElapsed = now.isBefore(todayFrom)
      ? Duration.zero
      : now.difference(todayFrom);
  final avoidedToday = math.max(
    0.0,
    todayElapsed.inSeconds / Duration.secondsPerDay * cigarettesPerDay -
        smoked.today,
  );
  final moneyToday = packSize <= 0 ? 0.0 : avoidedToday / packSize * packPrice;
  final moneySaved = ProgressCalculations.moneySaved(
    cigarettesAvoided: cigarettesAvoided,
    packPrice: packPrice,
    packSize: packSize,
  );
  final checkInDates = checkIns
      .map((record) => StreakCalculations.parseLocalDateKey(record.localDate))
      .nonNulls
      .toSet();
  final smokingDates = smokingLogs
      .map((record) => StreakCalculations.dateOnly(record.smokedAt))
      .toSet();
  final history = buildDayHistory(
    quitDate: baselineQuitDate,
    now: now,
    checkIns: checkIns,
    smokingLogs: smokingLogs,
  );
  final smokeFreeStreakDays = history.currentRun;
  final checkInStreakDays = StreakCalculations.consecutiveDayStreak(
    today: now,
    activeDates: checkInDates,
  );
  final honestyStreakDays = StreakCalculations.honestyStreakDaysFromActivity(
    today: now,
    checkInDates: checkInDates,
    smokingLogDates: smokingDates,
  );
  final resistanceStreak = StreakCalculations.resistanceStreak(
    cravings.map((session) => session.outcome).toList(),
  );

  return AsyncData(
    HomeDashboardData(
      smokeFreeDuration: smokeFreeDuration,
      smokeFreeSince: quitDate,
      cigarettesAvoided: cigarettesAvoided,
      moneySaved: moneySaved,
      currencySymbol: data.currencySymbol,
      cigarettesPerDay: cigarettesPerDay,
      packPrice: packPrice,
      packSize: packSize,
      smokeFreeDays: smokeFreeDuration.inDays,
      smokeFreeStreakDays: smokeFreeStreakDays,
      checkInStreakDays: checkInStreakDays,
      honestyStreakDays: honestyStreakDays,
      resistanceStreak: resistanceStreak,
      lastSmokeAt: loggedSmokeAt,
      todayCheckIn: checkIn,
      todaySealed: checkIn != null,
      moneyToday: moneyToday,
      cigarettesSmokedToday: smoked.today,
    ),
  );
});

/// Every day since the quit date, for runs, the week chain and the journal.
final dayHistoryProvider = Provider<DayHistory?>((ref) {
  final now = ref.watch(homeTickerProvider).value ?? DateTime.now();
  final baseline = ref.watch(homeBaselineProvider).value;
  if (baseline == null) {
    return null;
  }
  return buildDayHistory(
    quitDate: baseline.quitDate ?? now,
    now: now,
    checkIns: ref.watch(recentCheckInsProvider).value ?? const [],
    smokingLogs: ref.watch(recentSmokingLogsProvider).value ?? const [],
  );
});

/// A day counts as a slip when a cigarette was logged on it, or when it was
/// sealed as not smoke-free.
DayHistory buildDayHistory({
  required DateTime quitDate,
  required DateTime now,
  required List<DailyCheckInRecord> checkIns,
  required List<SmokingLogRecord> smokingLogs,
}) {
  DateTime? day(DailyCheckInRecord record) {
    return StreakCalculations.parseLocalDateKey(record.localDate);
  }

  return DayHistory(
    quitDate: quitDate,
    today: now,
    slipDays: [
      ...smokingLogs.map((log) => log.smokedAt),
      ...checkIns.where((record) => !record.smokeFreeToday).map(day).nonNulls,
    ],
    sealedDays: checkIns.map(day).nonNulls,
  );
}

/// Cigarettes smoked since the quit date, and today. A day's count is the
/// larger of what was logged and what its seal says, so nothing is doubled.
({int total, int today}) _cigarettesSmoked({
  required DateTime since,
  required DateTime now,
  required List<DailyCheckInRecord> checkIns,
  required List<SmokingLogRecord> smokingLogs,
}) {
  final quitDay = StreakCalculations.dateOnly(since);
  final byDay = <DateTime, int>{};
  for (final log in smokingLogs) {
    if (log.smokedAt.isBefore(since)) {
      continue;
    }
    byDay.update(
      StreakCalculations.dateOnly(log.smokedAt),
      (count) => count + log.count,
      ifAbsent: () => log.count,
    );
  }
  for (final record in checkIns) {
    final day = StreakCalculations.parseLocalDateKey(record.localDate);
    if (day == null || day.isBefore(quitDay)) {
      continue;
    }
    byDay.update(
      day,
      (count) => math.max(count, record.cigarettesSmoked),
      ifAbsent: () => record.cigarettesSmoked,
    );
  }
  return (
    total: byDay.values.fold(0, (sum, count) => sum + count),
    today: byDay[StreakCalculations.dateOnly(now)] ?? 0,
  );
}

final latestSmokeAtProvider = FutureProvider<DateTime?>((ref) async {
  return ref.watch(smokingLogRepositoryProvider).getLatestSmokedAt();
});

final todayCheckInProvider = FutureProvider<DailyCheckInRecord?>((ref) async {
  return ref.watch(dailyCheckInRepositoryProvider).getToday();
});

final recentCheckInsProvider = FutureProvider<List<DailyCheckInRecord>>((
  ref,
) async {
  return ref
      .watch(dailyCheckInRepositoryProvider)
      .getRecent(limit: _historyLimit);
});

final recentSmokingLogsProvider = FutureProvider<List<SmokingLogRecord>>((
  ref,
) async {
  return ref
      .watch(smokingLogRepositoryProvider)
      .getRecent(limit: _historyLimit);
});

final recentCravingsProvider = FutureProvider<List<CravingRescueData>>((
  ref,
) async {
  return ref.watch(cravingRepositoryProvider).recent(limit: _historyLimit);
});

class HomeDashboardData {
  const HomeDashboardData({
    required this.smokeFreeDuration,
    required this.cigarettesAvoided,
    required this.moneySaved,
    required this.currencySymbol,
    required this.cigarettesPerDay,
    required this.packPrice,
    required this.packSize,
    required this.smokeFreeDays,
    required this.smokeFreeStreakDays,
    required this.checkInStreakDays,
    required this.honestyStreakDays,
    required this.resistanceStreak,
    this.lastSmokeAt,
    this.todayCheckIn,
    this.todaySealed = false,
    this.moneyToday = 0,
    this.cigarettesSmokedToday = 0,
    DateTime? smokeFreeSince,
  }) : _smokeFreeSince = smokeFreeSince;

  final DateTime? _smokeFreeSince;

  /// When the current smoke-free period began (quit date or the last logged
  /// cigarette, whichever is later).
  DateTime get smokeFreeSince =>
      _smokeFreeSince ?? DateTime.now().subtract(smokeFreeDuration);

  final Duration smokeFreeDuration;
  final int cigarettesAvoided;
  final double moneySaved;
  final String currencySymbol;
  final int cigarettesPerDay;
  final double packPrice;
  final int packSize;
  final int smokeFreeDays;
  final int smokeFreeStreakDays;
  final int checkInStreakDays;
  final int honestyStreakDays;
  final int resistanceStreak;
  final DateTime? lastSmokeAt;
  final DailyCheckInRecord? todayCheckIn;

  /// Today has been closed with a seal.
  final bool todaySealed;

  /// Money kept since midnight.
  final double moneyToday;
  final int cigarettesSmokedToday;

  int get smokeFreeHours => smokeFreeDuration.inHours.remainder(24);
  int get smokeFreeMinutes => smokeFreeDuration.inMinutes.remainder(60);
  int get smokeFreeSeconds => smokeFreeDuration.inSeconds.remainder(60);

  String get liveClock {
    final hours = smokeFreeDuration.inHours.remainder(24);
    final minutes = smokeFreeDuration.inMinutes.remainder(60);
    final seconds = smokeFreeDuration.inSeconds.remainder(60);
    return '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

extension _StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
