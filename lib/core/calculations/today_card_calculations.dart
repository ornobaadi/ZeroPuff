import '../../models/craving_rescue_data.dart';
import '../../models/smoking_window_data.dart';
import '../utils/number_formatting.dart';
import 'streak_calculations.dart';

enum TodayCardKind { ritualSoon, sealDay, pledge, recap, goal, insight, steady }

/// The one thing Home puts in front of the user right now.
class TodayCard {
  const TodayCard({
    required this.kind,
    required this.title,
    required this.body,
    this.actionLabel,
    this.progress,
  });

  final TodayCardKind kind;
  final String title;
  final String body;

  /// Shown as a button when the card asks for something.
  final String? actionLabel;

  /// 0 to 1, for cards that track something.
  final double? progress;
}

class TodayCardCalculations {
  const TodayCardCalculations._();

  /// How close a ritual has to be to take over the card.
  static const ritualLeadMinutes = 45;
  static const ritualTailMinutes = 30;

  /// The hour from which the day can be sealed. Before it the morning
  /// promise is offered instead.
  static const sealFromHour = 18;

  /// Picks the most useful card for this moment, most urgent first: a smoking
  /// moment that is close, the morning promise or the evening seal, then
  /// something worth knowing.
  static TodayCard pick({
    required DateTime now,
    required List<SmokingWindowData> rituals,
    required bool pledgedToday,
    required bool sealedToday,
    required List<CravingRescueData> cravings,
    required double moneyPerCigarette,
    required String currencySymbol,
    required double moneySaved,
    String? goalName,
    double? goalTarget,
    List<String> insights = const [],
  }) {
    final nowMinutes = now.hour * 60 + now.minute;
    final today =
        rituals
            .where(
              (ritual) =>
                  ritual.enabled && ritual.daysOfWeek.contains(now.weekday),
            )
            .toList()
          ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    for (final ritual in today) {
      final until = ritual.startMinutes - nowMinutes;
      if (until <= ritualLeadMinutes && until >= -ritualTailMinutes) {
        return TodayCard(
          kind: TodayCardKind.ritualSoon,
          title: until > 0
              ? '${ritual.label} in $until min'
              : '${ritual.label} time',
          body: 'This one used to mean a cigarette. Six slow breaths first.',
          actionLabel: 'Breathe now',
        );
      }
    }

    final evening = now.hour >= sealFromHour;
    if (evening && !sealedToday) {
      return const TodayCard(
        kind: TodayCardKind.sealDay,
        title: 'Seal today',
        body: 'One tap closes the day and banks it. It takes a few seconds.',
        actionLabel: 'Seal today',
      );
    }

    if (!pledgedToday && !evening) {
      return const TodayCard(
        kind: TodayCardKind.pledge,
        title: "Today's promise",
        body: 'Only today. Not forever, not this week. Just today.',
        actionLabel: 'Not today',
      );
    }

    final yesterday = StreakCalculations.dateOnly(
      DateTime(now.year, now.month, now.day - 1),
    );
    final beaten = cravings
        .where(
          (craving) =>
              craving.resisted &&
              StreakCalculations.dateOnly(craving.startedAt) == yesterday,
        )
        .length;
    if (beaten > 0) {
      final kept = beaten * moneyPerCigarette;
      return TodayCard(
        kind: TodayCardKind.recap,
        title: beaten == 1
            ? 'Yesterday you beat a craving'
            : 'Yesterday you beat $beaten cravings',
        body: kept > 0
            ? 'That alone kept ${formatMoney(currencySymbol, kept)} in your pocket.'
            : 'Each one makes the next a little easier.',
      );
    }

    if (goalName != null && goalTarget != null && goalTarget > 0) {
      final progress = (moneySaved / goalTarget).clamp(0.0, 1.0);
      final left = goalTarget - moneySaved;
      return TodayCard(
        kind: TodayCardKind.goal,
        title: '$goalName: ${(progress * 100).round()}%',
        body: left <= 0
            ? 'You have saved enough. Go and get it.'
            : '${formatMoney(currencySymbol, left)} to go.',
        progress: progress,
      );
    }

    if (insights.isNotEmpty) {
      // A different one each day, the same all day.
      final dayNumber = now.difference(DateTime(now.year)).inDays;
      return TodayCard(
        kind: TodayCardKind.insight,
        title: 'From your pattern',
        body: insights[dayNumber % insights.length],
      );
    }

    final next = today
        .where((ritual) => ritual.startMinutes > nowMinutes)
        .firstOrNull;
    if (next != null) {
      return TodayCard(
        kind: TodayCardKind.steady,
        title: 'Next up: ${next.label}',
        body:
            'Around ${SmokingWindowData.labelForMinutes(next.startMinutes)}. ZeroPuff will check in a little before.',
      );
    }
    return const TodayCard(
      kind: TodayCardKind.steady,
      title: 'Cravings pass in minutes',
      body: 'When one shows up, hold the orb and breathe until it does.',
    );
  }
}
