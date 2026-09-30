import 'package:flutter/foundation.dart';

import '../../../models/onboarding_data.dart';
import '../../../models/profile_data.dart';
import '../../../models/smoking_window_data.dart';

/// Which quick option produced the quit date.
enum QuitDateChoice { today, yesterday, custom }

@immutable
class CurrencyOption {
  const CurrencyOption(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  /// Currencies with large nominal prices step in tens.
  bool get largePriceStep => code == 'BDT' || code == 'INR';

  static const all = [
    CurrencyOption('USD', r'$', 'US dollar'),
    CurrencyOption('EUR', '€', 'Euro'),
    CurrencyOption('GBP', '£', 'British pound'),
    CurrencyOption('INR', '₹', 'Indian rupee'),
    CurrencyOption('BDT', '৳', 'Bangladeshi taka'),
  ];

  static CurrencyOption byCode(String code) {
    return all.firstWhere((option) => option.code == code, orElse: () => all[0]);
  }
}

@immutable
class TriggerOption {
  const TriggerOption(this.value, this.label);

  final String value;
  final String label;
}

/// Everything the user enters during onboarding, with validation.
///
/// Pure Dart (no Flutter widgets) so it is easy to unit test.
@immutable
class OnboardingForm {
  const OnboardingForm({
    required this.quitDate,
    this.dateChoice = QuitDateChoice.today,
    this.cigarettesPerDay = 10,
    this.packPrice = 12,
    this.packSize = 20,
    this.currency = const CurrencyOption('USD', r'$', 'US dollar'),
    this.smokeWindowStartMinutes = 18 * 60,
    this.smokeWindowEndMinutes = 23 * 60,
    this.triggers = const {},
    this.reason = '',
  });

  static const minWindowMinutes = 30;
  static const maxReasonLength = 200;

  final DateTime quitDate;
  final QuitDateChoice dateChoice;
  final int cigarettesPerDay;
  final int packPrice;
  final int packSize;
  final CurrencyOption currency;
  final int smokeWindowStartMinutes;
  final int smokeWindowEndMinutes;
  final Set<String> triggers;
  final String reason;

  factory OnboardingForm.initial({DateTime? now}) {
    return OnboardingForm(quitDate: now ?? DateTime.now());
  }

  /// Restores a saved draft (used when the app is reopened mid-onboarding).
  factory OnboardingForm.fromDraft(OnboardingData draft, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final quitDate = draft.quitDate == null || draft.quitDate!.isAfter(current)
        ? current
        : draft.quitDate!;
    return OnboardingForm(
      quitDate: quitDate,
      dateChoice: _choiceFor(quitDate, current),
      cigarettesPerDay: draft.cigarettesPerDay ?? 10,
      packPrice: (draft.packPrice ?? 12).round(),
      packSize: draft.packSize ?? 20,
      currency: CurrencyOption.byCode(draft.currencyCode),
      smokeWindowStartMinutes: draft.usualSmokingWindow.startMinutes,
      smokeWindowEndMinutes: draft.usualSmokingWindow.endMinutes,
      triggers: draft.triggers.toSet(),
      reason: draft.quitReason ?? '',
    );
  }

  static QuitDateChoice _choiceFor(DateTime date, DateTime now) {
    if (isSameDay(date, now)) {
      return QuitDateChoice.today;
    }
    if (isSameDay(date, DateTime(now.year, now.month, now.day - 1))) {
      return QuitDateChoice.yesterday;
    }
    return QuitDateChoice.custom;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// A quit date on a chosen calendar day, keeping the current time of day so
  /// that "today" is never in the future.
  static DateTime dateOnDay(DateTime day, DateTime now) {
    if (isSameDay(day, now)) {
      return now;
    }
    return DateTime(day.year, day.month, day.day, now.hour, now.minute);
  }

  OnboardingForm copyWith({
    DateTime? quitDate,
    QuitDateChoice? dateChoice,
    int? cigarettesPerDay,
    int? packPrice,
    int? packSize,
    CurrencyOption? currency,
    int? smokeWindowStartMinutes,
    int? smokeWindowEndMinutes,
    Set<String>? triggers,
    String? reason,
  }) {
    return OnboardingForm(
      quitDate: quitDate ?? this.quitDate,
      dateChoice: dateChoice ?? this.dateChoice,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      packPrice: packPrice ?? this.packPrice,
      packSize: packSize ?? this.packSize,
      currency: currency ?? this.currency,
      smokeWindowStartMinutes:
          smokeWindowStartMinutes ?? this.smokeWindowStartMinutes,
      smokeWindowEndMinutes:
          smokeWindowEndMinutes ?? this.smokeWindowEndMinutes,
      triggers: triggers ?? this.triggers,
      reason: reason ?? this.reason,
    );
  }

  // ---- Validation ---------------------------------------------------------

  String? quitDateError(DateTime now) {
    if (quitDate.isAfter(now.add(const Duration(minutes: 1)))) {
      return 'The start date cannot be in the future.';
    }
    return null;
  }

  String? get cigarettesError =>
      cigarettesPerDay < 1 ? 'Enter at least 1 cigarette per day.' : null;

  String? get packSizeError =>
      packSize < 1 ? 'A pack needs at least 1 cigarette.' : null;

  String? get packPriceError =>
      packPrice < 0 ? 'The price cannot be negative.' : null;

  String? get windowError {
    if (smokeWindowEndMinutes - smokeWindowStartMinutes < minWindowMinutes) {
      return 'Make the window at least $minWindowMinutes minutes long.';
    }
    return null;
  }

  String? get triggersError =>
      triggers.isEmpty ? 'Pick at least one so we can tailor your rescue.' : null;

  /// Whether the user may leave [step] (see the step indices on the screen).
  bool canContinueFrom(int step, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return switch (step) {
      1 => quitDateError(current) == null,
      2 =>
        cigarettesError == null &&
            packSizeError == null &&
            packPriceError == null,
      3 => windowError == null && triggersError == null,
      _ => true,
    };
  }

  // ---- Mapping ------------------------------------------------------------

  String? get trimmedReason {
    final value = reason.trim();
    return value.isEmpty ? null : value;
  }

  SmokingWindowData get smokingWindow => SmokingWindowData(
    startMinutes: smokeWindowStartMinutes,
    endMinutes: smokeWindowEndMinutes,
  );

  OnboardingData toDraft({required int step, required bool completed}) {
    return OnboardingData(
      quitDate: quitDate,
      cigarettesPerDay: cigarettesPerDay,
      packPrice: packPrice.toDouble(),
      packSize: packSize,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      triggers: triggers.toList(),
      quitReason: trimmedReason,
      usualSmokingWindow: smokingWindow,
      currentStep: step,
      completed: completed,
    );
  }

  ProfileData toProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) {
    return ProfileData(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      quitDate: quitDate,
      cigarettesPerDay: cigarettesPerDay,
      packPrice: packPrice.toDouble(),
      packSize: packSize,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      triggers: triggers.toList(),
      usualSmokingWindow: smokingWindow,
      quitReason: trimmedReason,
    );
  }
}
