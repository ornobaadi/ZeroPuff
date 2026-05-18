import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../models/onboarding_data.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

final homeTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  ).startWith(DateTime.now());
});

final homeBaselineProvider = FutureProvider<OnboardingData>((ref) async {
  final draft = await ref.watch(onboardingRepositoryProvider).loadDraft();
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

  if (baseline is AsyncLoading ||
      latestSmoke is AsyncLoading ||
      todayCheckIn is AsyncLoading) {
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

  final data = baseline.value;
  if (data == null) {
    return const AsyncLoading<HomeDashboardData>();
  }

  final loggedSmokeAt = latestSmoke.value;
  final checkIn = todayCheckIn.value;
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
  final cigarettesAvoided = ProgressCalculations.cigarettesAvoided(
    smokeFreeDuration: smokeFreeDuration,
    cigarettesPerDay: cigarettesPerDay,
  );
  final moneySaved = ProgressCalculations.moneySaved(
    cigarettesAvoided: cigarettesAvoided,
    packPrice: packPrice,
    packSize: packSize,
  );

  return AsyncData(
    HomeDashboardData(
      smokeFreeDuration: smokeFreeDuration,
      cigarettesAvoided: cigarettesAvoided,
      moneySaved: moneySaved,
      currencySymbol: data.currencySymbol,
      smokeFreeDays: smokeFreeDuration.inDays,
      honestyStreakDays: checkIn == null ? 0 : 1,
      lastSmokeAt: loggedSmokeAt,
      todayCheckIn: checkIn,
    ),
  );
});

final latestSmokeAtProvider = FutureProvider<DateTime?>((ref) async {
  return ref.watch(smokingLogRepositoryProvider).getLatestSmokedAt();
});

final todayCheckInProvider = FutureProvider<DailyCheckInRecord?>((ref) async {
  return ref.watch(dailyCheckInRepositoryProvider).getToday();
});

final recentCheckInsProvider = FutureProvider<List<DailyCheckInRecord>>((
  ref,
) async {
  return ref.watch(dailyCheckInRepositoryProvider).getRecent();
});

class HomeDashboardData {
  const HomeDashboardData({
    required this.smokeFreeDuration,
    required this.cigarettesAvoided,
    required this.moneySaved,
    required this.currencySymbol,
    required this.smokeFreeDays,
    required this.honestyStreakDays,
    this.lastSmokeAt,
    this.todayCheckIn,
  });

  final Duration smokeFreeDuration;
  final int cigarettesAvoided;
  final double moneySaved;
  final String currencySymbol;
  final int smokeFreeDays;
  final int honestyStreakDays;
  final DateTime? lastSmokeAt;
  final DailyCheckInRecord? todayCheckIn;

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
