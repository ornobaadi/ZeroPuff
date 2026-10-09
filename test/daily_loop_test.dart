import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/craving_analysis_calculations.dart';
import 'package:zeropuff/core/calculations/today_card_calculations.dart';
import 'package:zeropuff/features/notifications/reminder_refresh.dart';
import 'package:zeropuff/models/craving_rescue_data.dart';
import 'package:zeropuff/models/smoking_window_data.dart';
import 'package:zeropuff/repositories/daily_loop_repository.dart';
import 'package:zeropuff/services/notifications/notification_service.dart';

void main() {
  // A Wednesday.
  final now = DateTime(2026, 10, 7, 13, 0);

  SmokingWindowData ritual(String label, int hour, {int minute = 0}) {
    return SmokingWindowData.ritual(
      windowId: label,
      label: label,
      startMinutes: hour * 60 + minute,
    );
  }

  CravingRescueData craving(
    DateTime at, {
    String outcome = 'resisted',
    List<String> triggers = const [],
  }) {
    return CravingRescueData(
      sessionId: at.toIso8601String(),
      startedAt: at,
      intensity: 6,
      triggers: triggers,
      outcome: outcome,
    );
  }

  TodayCard pick({
    List<SmokingWindowData> rituals = const [],
    bool pledgedToday = true,
    List<CravingRescueData> cravings = const [],
    String? goalName,
    double? goalTarget,
    List<String> insights = const [],
  }) {
    return TodayCardCalculations.pick(
      now: now,
      rituals: rituals,
      pledgedToday: pledgedToday,
      cravings: cravings,
      moneyPerCigarette: 0.5,
      currencySymbol: r'$',
      moneySaved: 30,
      goalName: goalName,
      goalTarget: goalTarget,
      insights: insights,
    );
  }

  group('Today card', () {
    test('a smoking moment that is close comes before everything else', () {
      final card = pick(
        rituals: [ritual('After lunch', 13, minute: 30)],
        pledgedToday: false,
      );

      expect(card.kind, TodayCardKind.ritualSoon);
      expect(card.title, 'After lunch in 30 min');
      expect(card.actionLabel, 'Breathe now');
    });

    test('a moment that is hours away does not take over', () {
      final card = pick(rituals: [ritual('Before bed', 23)]);

      expect(card.kind, TodayCardKind.steady);
      expect(card.title, 'Next up: Before bed');
    });

    test('a switched-off moment is ignored', () {
      final off = ritual('After lunch', 13, minute: 10).copyWith(enabled: false);

      expect(pick(rituals: [off]).kind, TodayCardKind.steady);
    });

    test('asks for the promise until it is made', () {
      expect(pick(pledgedToday: false).kind, TodayCardKind.pledge);
      expect(pick().kind, isNot(TodayCardKind.pledge));
    });

    test('recaps cravings beaten yesterday, not ones lost or older', () {
      final card = pick(
        cravings: [
          craving(DateTime(2026, 10, 6, 9)),
          craving(DateTime(2026, 10, 6, 21)),
          craving(DateTime(2026, 10, 6, 22), outcome: 'smoked'),
          craving(DateTime(2026, 10, 5, 9)),
        ],
      );

      expect(card.kind, TodayCardKind.recap);
      expect(card.title, 'Yesterday you beat 2 cravings');
      expect(card.body, contains(r'$1'));
    });

    test('shows progress to a savings goal', () {
      final card = pick(goalName: 'Headphones', goalTarget: 120);

      expect(card.kind, TodayCardKind.goal);
      expect(card.title, 'Headphones: 25%');
      expect(card.progress, 0.25);
    });

    test('falls back to an insight, then to a steady line', () {
      expect(pick(insights: ['Stress shows up most often.']).kind,
          TodayCardKind.insight);
      expect(pick().title, 'Cravings pass in minutes');
    });
  });

  group('Nudge moments', () {
    final usual = const SmokingWindowData(
      startMinutes: 18 * 60,
      endMinutes: 23 * 60,
    );

    test('rituals replace the single usual window', () {
      final moments = nudgeMoments(
        rituals: [ritual('Morning coffee', 9)],
        usualWindow: usual,
        cravings: const [],
        now: now,
      );

      expect(moments.map((moment) => moment.label), ['Morning coffee']);
    });

    test('the usual window is used when there are no rituals', () {
      final moments = nudgeMoments(
        rituals: const [],
        usualWindow: usual,
        cravings: const [],
        now: now,
      );

      expect(moments.single.isPrimary, isTrue);
    });

    test('adds the learned peak only when no moment covers it', () {
      final lateNight = [
        for (var day = 1; day <= 14; day++)
          craving(DateTime(2026, 9, day, 15, 20)),
      ];

      final uncovered = nudgeMoments(
        rituals: [ritual('Morning coffee', 9)],
        usualWindow: usual,
        cravings: lateNight,
        now: now,
      );
      expect(uncovered.last.source, 'learned');
      expect(uncovered.last.startMinutes, 15 * 60);

      final covered = nudgeMoments(
        rituals: [ritual('Afternoon break', 16)],
        usualWindow: usual,
        cravings: lateNight,
        now: now,
      );
      expect(covered.where((moment) => moment.source == 'learned'), isEmpty);
    });
  });

  test('ritual nudges name the moment', () {
    final copy = NotificationService.ritualCopy(ritual('Morning coffee', 9));

    expect(copy.title, 'Morning coffee is coming up');
  });

  group('Likely triggers', () {
    test('suggests the trigger that repeats around this time of day', () {
      final likely = CravingAnalysisCalculations.likelyTriggers(
        cravings: [
          craving(DateTime(2026, 10, 1, 13, 10), triggers: ['after food']),
          craving(DateTime(2026, 10, 2, 12, 40), triggers: ['after food']),
          craving(DateTime(2026, 10, 3, 22, 0), triggers: ['stress']),
          craving(DateTime(2026, 10, 4, 22, 0), triggers: ['stress']),
        ],
        now: now,
      );

      expect(likely, ['after food']);
    });

    test('suggests nothing from a single craving', () {
      final likely = CravingAnalysisCalculations.likelyTriggers(
        cravings: [
          craving(DateTime(2026, 10, 1, 13, 10), triggers: ['after food']),
        ],
        now: now,
      );

      expect(likely, isEmpty);
    });
  });

  test('a savings goal reports its progress', () {
    const goal = SavingsGoal(name: 'Headphones', target: 200);

    expect(goal.progress(50), 0.25);
    expect(goal.progress(500), 1);
    expect(goal.reachedWith(199), isFalse);
    expect(goal.reachedWith(200), isTrue);
  });
}
