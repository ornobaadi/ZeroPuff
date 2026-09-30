import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/features/onboarding/models/onboarding_form.dart';
import 'package:zeropuff/models/onboarding_data.dart';
import 'package:zeropuff/models/smoking_window_data.dart';

void main() {
  final now = DateTime(2026, 9, 30, 14, 30);

  group('OnboardingForm validation', () {
    test('accepts sensible defaults once a trigger is chosen', () {
      final form = OnboardingForm.initial(
        now: now,
      ).copyWith(triggers: {'stress'});

      for (final step in [1, 2, 3, 4, 5]) {
        expect(form.canContinueFrom(step, now: now), isTrue, reason: '$step');
      }
    });

    test('blocks a start date in the future', () {
      final form = OnboardingForm.initial(
        now: now,
      ).copyWith(quitDate: now.add(const Duration(days: 2)));

      expect(form.quitDateError(now), isNotNull);
      expect(form.canContinueFrom(1, now: now), isFalse);
    });

    test('requires at least one cigarette per day', () {
      final form = OnboardingForm.initial(now: now).copyWith(cigarettesPerDay: 0);

      expect(form.cigarettesError, isNotNull);
      expect(form.canContinueFrom(2, now: now), isFalse);
    });

    test('requires a positive pack size and a non-negative price', () {
      final form = OnboardingForm.initial(now: now);

      expect(form.copyWith(packSize: 0).packSizeError, isNotNull);
      expect(form.copyWith(packPrice: -1).packPriceError, isNotNull);
      expect(form.copyWith(packPrice: 0).packPriceError, isNull);
    });

    test('requires a smoking window of at least 30 minutes', () {
      final form = OnboardingForm.initial(now: now).copyWith(
        triggers: {'stress'},
        smokeWindowStartMinutes: 600,
        smokeWindowEndMinutes: 615,
      );

      expect(form.windowError, isNotNull);
      expect(form.canContinueFrom(3, now: now), isFalse);
    });

    test('requires at least one trigger', () {
      final form = OnboardingForm.initial(now: now);

      expect(form.triggersError, isNotNull);
      expect(form.canContinueFrom(3, now: now), isFalse);
    });
  });

  group('OnboardingForm dates', () {
    test('today keeps the exact current time', () {
      expect(OnboardingForm.dateOnDay(now, now), now);
    });

    test('an earlier day keeps the current time of day', () {
      final date = OnboardingForm.dateOnDay(DateTime(2026, 9, 1), now);

      expect(date, DateTime(2026, 9, 1, 14, 30));
    });
  });

  group('OnboardingForm drafts', () {
    test('round-trips through a draft', () {
      final form = OnboardingForm.initial(now: now).copyWith(
        quitDate: DateTime(2026, 9, 1, 8),
        dateChoice: QuitDateChoice.custom,
        cigarettesPerDay: 15,
        packPrice: 9,
        packSize: 25,
        currency: CurrencyOption.byCode('GBP'),
        smokeWindowStartMinutes: 8 * 60,
        smokeWindowEndMinutes: 10 * 60,
        triggers: {'coffee', 'stress'},
        reason: '  For my family  ',
      );

      final restored = OnboardingForm.fromDraft(
        form.toDraft(step: 3, completed: false),
        now: now,
      );

      expect(restored.cigarettesPerDay, 15);
      expect(restored.packPrice, 9);
      expect(restored.packSize, 25);
      expect(restored.currency.code, 'GBP');
      expect(restored.smokeWindowStartMinutes, 480);
      expect(restored.smokeWindowEndMinutes, 600);
      expect(restored.triggers, {'coffee', 'stress'});
      expect(restored.trimmedReason, 'For my family');
      expect(restored.dateChoice, QuitDateChoice.custom);
    });

    test('ignores a draft start date that is in the future', () {
      final draft = OnboardingData(quitDate: now.add(const Duration(days: 5)));

      final restored = OnboardingForm.fromDraft(draft, now: now);

      expect(restored.quitDate, now);
      expect(restored.dateChoice, QuitDateChoice.today);
    });

    test('maps to a profile', () {
      final form = OnboardingForm.initial(
        now: now,
      ).copyWith(triggers: {'stress'}, reason: '');

      final profile = form.toProfile(userId: 'u1', displayName: 'Guest');

      expect(profile.userId, 'u1');
      expect(profile.quitReason, isNull);
      expect(profile.usualSmokingWindow, isA<SmokingWindowData>());
      expect(profile.currencyCode, 'USD');
    });
  });
}
