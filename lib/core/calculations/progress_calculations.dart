class ProgressCalculations {
  const ProgressCalculations._();

  static const streakMilestones = [
    ProgressMilestone(
      key: '20_minutes',
      title: '20 minutes',
      body: 'Your first 20 smoke-free minutes are on the board.',
      duration: Duration(minutes: 20),
      badgeAsset: 'assets/badges/20min.png',
    ),
    ProgressMilestone(
      key: '12_hours',
      title: '12 hours',
      body: 'Half a day without smoking. Keep the momentum going.',
      duration: Duration(hours: 12),
      badgeAsset: 'assets/badges/8h.png',
    ),
    ProgressMilestone(
      key: '2_weeks',
      title: '2 weeks',
      body: 'Two weeks in. New routines are starting to replace old ones.',
      duration: Duration(days: 14),
      badgeAsset: 'assets/badges/2w.png',
    ),
    ProgressMilestone(
      key: '1_month',
      title: '1 month',
      body: 'A full month smoke-free. That is a real habit shift.',
      duration: Duration(days: 30),
      badgeAsset: 'assets/badges/1m.png',
    ),
    ProgressMilestone(
      key: '3_months',
      title: '3 months',
      body: 'Three months of choosing differently, one day at a time.',
      duration: Duration(days: 90),
      badgeAsset: 'assets/badges/3m.png',
    ),
    ProgressMilestone(
      key: '9_months',
      title: '9 months',
      body: 'Nine months strong. Your new routine is well established.',
      duration: Duration(days: 270),
      badgeAsset: 'assets/badges/3m.png',
    ),
    ProgressMilestone(
      key: '1_year',
      title: '1 year',
      body: 'One full year smoke-free. Worth celebrating.',
      duration: Duration(days: 365),
      badgeAsset: 'assets/badges/1y.png',
    ),
    ProgressMilestone(
      key: '5_years',
      title: '5 years',
      body: 'Five years of staying the course.',
      duration: Duration(days: 365 * 5),
      badgeAsset: 'assets/badges/1y.png',
    ),
    ProgressMilestone(
      key: '10_years',
      title: '10 years',
      body: 'A decade smoke-free. Remarkable consistency.',
      duration: Duration(days: 365 * 10),
      badgeAsset: 'assets/badges/1y.png',
    ),
    ProgressMilestone(
      key: '15_years',
      title: '15 years',
      body: 'Fifteen years and counting. Smoking is well behind you.',
      duration: Duration(days: 365 * 15),
      badgeAsset: 'assets/badges/1y.png',
    ),
  ];

  static const achievements = [
    ProgressMilestone(
      key: '20_minutes',
      title: 'First Reset',
      body: 'Stay smoke-free for the first 20 minutes.',
      duration: Duration(minutes: 20),
      badgeAsset: 'assets/badges/20min.png',
    ),
    ProgressMilestone(
      key: '8_hours',
      title: 'Clear Start',
      body: 'Protect 8 smoke-free hours.',
      duration: Duration(hours: 8),
      badgeAsset: 'assets/badges/8h.png',
    ),
    ProgressMilestone(
      key: '24_hours',
      title: 'First Full Day',
      body: 'Complete 24 hours without smoking.',
      duration: Duration(hours: 24),
      badgeAsset: 'assets/badges/24h.png',
    ),
    ProgressMilestone(
      key: '48_hours',
      title: 'Two-Day Spark',
      body: 'Reach 48 smoke-free hours.',
      duration: Duration(hours: 48),
      badgeAsset: 'assets/badges/48h.png',
    ),
    ProgressMilestone(
      key: '1_week',
      title: 'Week Warrior',
      body: 'Build a 1-week smoke-free chain.',
      duration: Duration(days: 7),
      badgeAsset: 'assets/badges/1w.png',
    ),
    ProgressMilestone(
      key: '2_weeks',
      title: 'Routine Breaker',
      body: 'Keep going for 2 full weeks.',
      duration: Duration(days: 14),
      badgeAsset: 'assets/badges/2w.png',
    ),
    ProgressMilestone(
      key: '1_month',
      title: 'Month Builder',
      body: 'Reach one month smoke-free.',
      duration: Duration(days: 30),
      badgeAsset: 'assets/badges/1m.png',
    ),
    ProgressMilestone(
      key: '3_months',
      title: 'Craving Tamer',
      body: 'Reach three months smoke-free.',
      duration: Duration(days: 90),
      badgeAsset: 'assets/badges/3m.png',
    ),
    ProgressMilestone(
      key: '1_year',
      title: 'Year Legend',
      body: 'Protect a full year smoke-free.',
      duration: Duration(days: 365),
      badgeAsset: 'assets/badges/1y.png',
    ),
    ProgressMilestone(
      key: '10_cravings',
      title: 'Craving Scout',
      body: 'Log 10 cravings and learn your patterns.',
      duration: Duration.zero,
      badgeAsset: 'assets/badges/10crave.png',
      cravingCountTarget: 10,
    ),
    ProgressMilestone(
      key: '100_avoided',
      title: 'Hundred Saved',
      body: 'Avoid 100 cigarettes compared with your old pace.',
      duration: Duration.zero,
      badgeAsset: 'assets/badges/100avoid.png',
      cigarettesAvoidedTarget: 100,
    ),
    ProgressMilestone(
      key: '50_saved',
      title: 'Pocket Win',
      body: 'Save your first 50 in cigarette money.',
      duration: Duration.zero,
      badgeAsset: r'assets/badges/$50.png',
      moneySavedTarget: 50,
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

  static String durationLabel(Duration duration) {
    if (duration <= Duration.zero) {
      return '0 min';
    }
    if (duration.inDays >= 30) {
      final months = duration.inDays ~/ 30;
      return months == 1 ? '1 month' : '$months months';
    }
    if (duration.inDays >= 1) {
      return duration.inDays == 1 ? '1 day' : '${duration.inDays} days';
    }
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes == 0) {
        return hours == 1 ? '1h' : '${hours}h';
      }
      return '${hours}h ${minutes}m';
    }
    return duration.inMinutes == 1 ? '1 min' : '${duration.inMinutes} min';
  }

  static ProgressMilestone? nextMilestone(Duration smokeFreeDuration) {
    for (final milestone in streakMilestones) {
      if (smokeFreeDuration < milestone.duration) {
        return milestone;
      }
    }
    return null;
  }

  static ProgressMilestone currentMilestone(Duration smokeFreeDuration) {
    ProgressMilestone current = streakMilestones.first;
    for (final milestone in streakMilestones) {
      if (smokeFreeDuration >= milestone.duration) {
        current = milestone;
      } else {
        break;
      }
    }
    return current;
  }

  static ProgressMilestone? previousMilestone(ProgressMilestone milestone) {
    final index = streakMilestones.indexWhere(
      (item) => item.key == milestone.key,
    );
    if (index <= 0) {
      return null;
    }
    return streakMilestones[index - 1];
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
        .where(
          (achievement) =>
              achievement.duration > Duration.zero &&
              smokeFreeDuration >= achievement.duration,
        )
        .map((achievement) => achievement.key)
        .toSet();
  }

  static Set<String> unlockedAchievementKeysForStats({
    required Duration smokeFreeDuration,
    required int cravingCount,
    required int cigarettesAvoided,
    required double moneySaved,
  }) {
    return achievements
        .where(
          (achievement) => achievement.isUnlocked(
            smokeFreeDuration: smokeFreeDuration,
            cravingCount: cravingCount,
            cigarettesAvoided: cigarettesAvoided,
            moneySaved: moneySaved,
          ),
        )
        .map((achievement) => achievement.key)
        .toSet();
  }

  static Set<String> unlockedMilestoneKeys(Duration smokeFreeDuration) {
    return streakMilestones
        .where((milestone) => smokeFreeDuration >= milestone.duration)
        .map((milestone) => milestoneAchievementKey(milestone.key))
        .toSet();
  }

  static String milestoneAchievementKey(String key) {
    // Prefix kept for compatibility with already-stored achievement keys.
    return 'health_milestone_$key';
  }

  static String milestoneKeyFromAchievement(String achievementKey) {
    return achievementKey.replaceFirst('health_milestone_', '');
  }
}

class ProgressMilestone {
  const ProgressMilestone({
    required this.key,
    required this.title,
    required this.body,
    required this.duration,
    this.badgeAsset,
    this.cravingCountTarget,
    this.cigarettesAvoidedTarget,
    this.moneySavedTarget,
  });

  final String key;
  final String title;
  final String body;
  final Duration duration;
  final String? badgeAsset;
  final int? cravingCountTarget;
  final int? cigarettesAvoidedTarget;
  final double? moneySavedTarget;

  bool isUnlocked({
    required Duration smokeFreeDuration,
    required int cravingCount,
    required int cigarettesAvoided,
    required double moneySaved,
  }) {
    if (duration > Duration.zero && smokeFreeDuration < duration) {
      return false;
    }
    final cravings = cravingCountTarget;
    if (cravings != null && cravingCount < cravings) {
      return false;
    }
    final avoided = cigarettesAvoidedTarget;
    if (avoided != null && cigarettesAvoided < avoided) {
      return false;
    }
    final saved = moneySavedTarget;
    if (saved != null && moneySaved < saved) {
      return false;
    }
    return duration > Duration.zero ||
        cravingCountTarget != null ||
        cigarettesAvoidedTarget != null ||
        moneySavedTarget != null;
  }
}
