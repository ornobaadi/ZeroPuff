import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/onboarding_data.dart';
import '../../../repositories/onboarding_repository.dart';

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

  return baseline.whenData((data) {
    final quitDate = data.quitDate ?? now;
    final smokeFreeDuration = now.isBefore(quitDate)
        ? Duration.zero
        : now.difference(quitDate);
    final cigarettesPerDay = data.cigarettesPerDay ?? 0;
    final packSize = data.packSize ?? 20;
    final packPrice = data.packPrice ?? 0;
    final daysAsDouble = smokeFreeDuration.inSeconds / Duration.secondsPerDay;
    final cigarettesAvoided = (daysAsDouble * cigarettesPerDay).floor();
    final moneySaved = packSize <= 0
        ? 0.0
        : (cigarettesAvoided / packSize) * packPrice;

    return HomeDashboardData(
      smokeFreeDuration: smokeFreeDuration,
      cigarettesAvoided: cigarettesAvoided,
      moneySaved: moneySaved,
      currencySymbol: data.currencySymbol,
      smokeFreeDays: smokeFreeDuration.inDays,
      honestyStreakDays: data.completed ? 1 : 0,
    );
  });
});

class HomeDashboardData {
  const HomeDashboardData({
    required this.smokeFreeDuration,
    required this.cigarettesAvoided,
    required this.moneySaved,
    required this.currencySymbol,
    required this.smokeFreeDays,
    required this.honestyStreakDays,
  });

  final Duration smokeFreeDuration;
  final int cigarettesAvoided;
  final double moneySaved;
  final String currencySymbol;
  final int smokeFreeDays;
  final int honestyStreakDays;

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
