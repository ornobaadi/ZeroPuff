class ProgressCalculations {
  const ProgressCalculations._();

  static const healthMilestones = [
    ProgressMilestone(
      key: '20_minutes',
      title: '20 minutes',
      body: 'Pulse and blood pressure begin to settle.',
      duration: Duration(minutes: 20),
    ),
    ProgressMilestone(
      key: '8_hours',
      title: '8 hours',
      body: 'Oxygen levels get more room to recover.',
      duration: Duration(hours: 8),
    ),
    ProgressMilestone(
      key: '24_hours',
      title: '24 hours',
      body: 'The first full-day marker becomes visible.',
      duration: Duration(hours: 24),
    ),
    ProgressMilestone(
      key: '48_hours',
      title: '48 hours',
      body: 'Taste and smell may start feeling sharper.',
      duration: Duration(hours: 48),
    ),
    ProgressMilestone(
      key: '72_hours',
      title: '72 hours',
      body: 'Breathing can begin to feel easier.',
      duration: Duration(hours: 72),
    ),
    ProgressMilestone(
      key: '1_week',
      title: '1 week',
      body: 'A full week of practice, data, and recovery.',
      duration: Duration(days: 7),
    ),
    ProgressMilestone(
      key: '2_weeks',
      title: '2 weeks',
      body: 'Circulation and routine stability keep building.',
      duration: Duration(days: 14),
    ),
    ProgressMilestone(
      key: '1_month',
      title: '1 month',
      body: 'The new pattern has real weight now.',
      duration: Duration(days: 30),
    ),
    ProgressMilestone(
      key: '3_months',
      title: '3 months',
      body: 'Craving patterns can feel more predictable and manageable.',
      duration: Duration(days: 90),
    ),
    ProgressMilestone(
      key: '1_year',
      title: '1 year',
      body: 'A year of decisions, data, and momentum.',
      duration: Duration(days: 365),
    ),
  ];

  static const achievements = [
    ProgressMilestone(
      key: '1_hour',
      title: '1 hour',
      body: '',
      duration: Duration(hours: 1),
    ),
    ProgressMilestone(
      key: '6_hours',
      title: '6 hours',
      body: '',
      duration: Duration(hours: 6),
    ),
    ProgressMilestone(
      key: '12_hours',
      title: '12 hours',
      body: '',
      duration: Duration(hours: 12),
    ),
    ProgressMilestone(
      key: '1_day',
      title: '1 day',
      body: '',
      duration: Duration(days: 1),
    ),
    ProgressMilestone(
      key: '3_days',
      title: '3 days',
      body: '',
      duration: Duration(days: 3),
    ),
    ProgressMilestone(
      key: '1_week',
      title: '1 week',
      body: '',
      duration: Duration(days: 7),
    ),
    ProgressMilestone(
      key: '2_weeks',
      title: '2 weeks',
      body: '',
      duration: Duration(days: 14),
    ),
    ProgressMilestone(
      key: '1_month',
      title: '1 month',
      body: '',
      duration: Duration(days: 30),
    ),
  ];

  static int cigarettesAvoided({
    required Duration smokeFreeDuration,
    required int cigarettesPerDay,
  }) {
    if (smokeFreeDuration <= Duration.zero || cigarettesPerDay <= 0) {
      return 0;
    }
    final days = smokeFreeDuration.inSeconds / Duration.secondsPerDay;
    return (days * cigarettesPerDay).floor();
  }

  static double moneySaved({
    required int cigarettesAvoided,
    required double packPrice,
    required int packSize,
  }) {
    if (cigarettesAvoided <= 0 || packPrice <= 0 || packSize <= 0) {
      return 0;
    }
    return (cigarettesAvoided / packSize) * packPrice;
  }

  static ProgressMilestone? nextMilestone(Duration smokeFreeDuration) {
    for (final milestone in healthMilestones) {
      if (smokeFreeDuration < milestone.duration) {
        return milestone;
      }
    }
    return null;
  }

  static double milestoneProgress({
    required Duration smokeFreeDuration,
    required ProgressMilestone milestone,
  }) {
    if (milestone.duration.inSeconds <= 0) {
      return 1;
    }
    return (smokeFreeDuration.inSeconds / milestone.duration.inSeconds).clamp(
      0.0,
      1.0,
    );
  }

  static Set<String> unlockedAchievementKeys(Duration smokeFreeDuration) {
    return achievements
        .where((achievement) => smokeFreeDuration >= achievement.duration)
        .map((achievement) => achievement.key)
        .toSet();
  }
}

class ProgressMilestone {
  const ProgressMilestone({
    required this.key,
    required this.title,
    required this.body,
    required this.duration,
  });

  final String key;
  final String title;
  final String body;
  final Duration duration;
}
