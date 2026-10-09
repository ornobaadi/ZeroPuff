/// Whether a milestone is reached by time passing or by something done.
enum MilestoneKind { time, earned }

/// Everything milestones are measured against.
class MilestoneStats {
  const MilestoneStats({
    required this.smokeFreeDuration,
    this.cravingsBeaten = 0,
    this.cigarettesAvoided = 0,
    this.packsAvoided = 0,
    this.sealedDays = 0,
    this.comeback = false,
  });

  /// Time since the last cigarette.
  final Duration smokeFreeDuration;
  final int cravingsBeaten;
  final int cigarettesAvoided;

  /// Packs' worth of cigarettes not smoked.
  final double packsAvoided;
  final int sealedDays;

  /// A craving was beaten after a slip had been logged.
  final bool comeback;
}

class ProgressCalculations {
  const ProgressCalculations._();

  /// Markers along the way that arrive with time. Keys are stored on the
  /// device and in the account, so they must not change.
  static const timeMilestones = [
    ProgressMilestone(
      key: '20_minutes',
      title: '20 minutes',
      name: 'First Reset',
      body: 'Your first 20 smoke-free minutes are on the board.',
      duration: Duration(minutes: 20),
      badgeAsset: 'assets/badges/20min.png',
    ),
    ProgressMilestone(
      key: '8_hours',
      title: '8 hours',
      name: 'Clear Start',
      body: 'Eight hours without one. The first stretch is behind you.',
      duration: Duration(hours: 8),
      badgeAsset: 'assets/badges/8h.png',
    ),
    ProgressMilestone(
      key: '24_hours',
      title: '24 hours',
      name: 'First Full Day',
      body: 'A full day smoke-free. That first day is real.',
      duration: Duration(hours: 24),
      badgeAsset: 'assets/badges/24h.png',
    ),
    ProgressMilestone(
      key: '48_hours',
      title: '48 hours',
      name: 'Two-Day Spark',
      body: 'Two days in. You have done the first day twice.',
      duration: Duration(hours: 48),
      badgeAsset: 'assets/badges/48h.png',
    ),
    ProgressMilestone(
      key: '72_hours',
      title: '3 days',
      name: 'Three Days Down',
      body: 'Three days in a row of choosing differently.',
      duration: Duration(hours: 72),
    ),
    ProgressMilestone(
      key: '1_week',
      title: '1 week',
      name: 'Week Warrior',
      body: 'A full week. Seven mornings without one.',
      duration: Duration(days: 7),
      badgeAsset: 'assets/badges/1w.png',
    ),
    ProgressMilestone(
      key: '2_weeks',
      title: '2 weeks',
      name: 'Routine Breaker',
      body: 'Two weeks in. New routines are starting to replace old ones.',
      duration: Duration(days: 14),
      badgeAsset: 'assets/badges/2w.png',
    ),
    ProgressMilestone(
      key: '1_month',
      title: '1 month',
      name: 'Month Builder',
      body: 'A full month smoke-free. That is a real habit shift.',
      duration: Duration(days: 30),
      badgeAsset: 'assets/badges/1m.png',
    ),
    ProgressMilestone(
      key: '3_months',
      title: '3 months',
      name: 'Craving Tamer',
      body: 'Three months of choosing differently, one day at a time.',
      duration: Duration(days: 90),
      badgeAsset: 'assets/badges/3m.png',
    ),
    ProgressMilestone(
      key: '6_months',
      title: '6 months',
      name: 'Half a Year',
      body: 'Half a year. Smoking is becoming something you used to do.',
      duration: Duration(days: 180),
    ),
    ProgressMilestone(
      key: '9_months',
      title: '9 months',
      name: 'Nine Months Strong',
      body: 'Nine months strong. Your new routine is well established.',
      duration: Duration(days: 270),
    ),
    ProgressMilestone(
      key: '1_year',
      title: '1 year',
      name: 'Year Legend',
      body: 'One full year smoke-free. Worth celebrating.',
      duration: Duration(days: 365),
      badgeAsset: 'assets/badges/1y.png',
    ),
    ProgressMilestone(
      key: '2_years',
      title: '2 years',
      name: 'Two Years On',
      body: 'Two years. This is simply how you live now.',
      duration: Duration(days: 365 * 2),
    ),
    ProgressMilestone(
      key: '5_years',
      title: '5 years',
      name: 'Five Years On',
      body: 'Five years of staying the course.',
      duration: Duration(days: 365 * 5),
    ),
    ProgressMilestone(
      key: '10_years',
      title: '10 years',
      name: 'A Decade Clear',
      body: 'A decade smoke-free. Remarkable consistency.',
      duration: Duration(days: 365 * 10),
    ),
  ];

  /// Badges for things done rather than time passed.
  static const earnedMilestones = [
    ProgressMilestone(
      key: 'first_craving',
      title: 'First Win',
      body: 'Beat your first craving.',
      cravingsBeatenTarget: 1,
    ),
    ProgressMilestone(
      key: '10_cravings',
      title: 'Craving Scout',
      body: 'Beat 10 cravings.',
      badgeAsset: 'assets/badges/10crave.png',
      cravingsBeatenTarget: 10,
    ),
    ProgressMilestone(
      key: '25_cravings',
      title: 'Steady Hands',
      body: 'Beat 25 cravings.',
      cravingsBeatenTarget: 25,
    ),
    ProgressMilestone(
      key: '50_cravings',
      title: 'Wave Rider',
      body: 'Beat 50 cravings.',
      cravingsBeatenTarget: 50,
    ),
    ProgressMilestone(
      key: '100_cravings',
      title: 'Unshakeable',
      body: 'Beat 100 cravings.',
      cravingsBeatenTarget: 100,
    ),
    ProgressMilestone(
      key: 'comeback',
      title: 'Back on the Path',
      body: 'Beat a craving after a slip.',
      comeback: true,
    ),
    ProgressMilestone(
      key: '100_avoided',
      title: 'Hundred Saved',
      body: 'Leave 100 cigarettes unsmoked.',
      badgeAsset: 'assets/badges/100avoid.png',
      cigarettesAvoidedTarget: 100,
    ),
    ProgressMilestone(
      key: '500_avoided',
      title: 'Five Hundred Down',
      body: 'Leave 500 cigarettes unsmoked.',
      cigarettesAvoidedTarget: 500,
    ),
    ProgressMilestone(
      key: '1000_avoided',
      title: 'A Thousand Unsmoked',
      body: 'Leave 1,000 cigarettes unsmoked.',
      cigarettesAvoidedTarget: 1000,
    ),
    ProgressMilestone(
      key: '1_pack',
      title: 'First Pack Kept',
      body: 'Keep the price of one pack in your pocket.',
      packsTarget: 1,
    ),
    ProgressMilestone(
      key: '10_packs',
      title: 'Ten Packs Kept',
      body: 'Keep the price of 10 packs.',
      packsTarget: 10,
    ),
    ProgressMilestone(
      key: '50_packs',
      title: 'Fifty Packs Kept',
      body: 'Keep the price of 50 packs.',
      packsTarget: 50,
    ),
    ProgressMilestone(
      key: '7_sealed',
      title: 'Seven Seals',
      body: 'Seal 7 days.',
      sealedDaysTarget: 7,
    ),
    ProgressMilestone(
      key: '30_sealed',
      title: 'Thirty Seals',
      body: 'Seal 30 days.',
      sealedDaysTarget: 30,
    ),
  ];

  static const milestones = [...timeMilestones, ...earnedMilestones];

  /// Keys saved by earlier versions for the same time milestones.
  static const legacyKeyPrefix = 'health_milestone_';

  static ProgressMilestone? byKey(String key) {
    for (final milestone in milestones) {
      if (milestone.key == key) {
        return milestone;
      }
    }
    return null;
  }

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

  /// "in 2 days", "in 3 h", "in 12 min": how far off something is.
  static String untilLabel(Duration remaining) {
    if (remaining <= Duration.zero) {
      return 'now';
    }
    if (remaining.inDays >= 60) {
      return 'in ${remaining.inDays ~/ 30} months';
    }
    if (remaining.inDays >= 2) {
      return 'in ${remaining.inDays} days';
    }
    if (remaining.inHours >= 1) {
      return 'in ${remaining.inHours} h';
    }
    final minutes = remaining.inMinutes < 1 ? 1 : remaining.inMinutes;
    return 'in $minutes min';
  }

  /// A countdown with two units while it is close: "in 2 days 7 h",
  /// "in 5 h 12 min", "in 12 min". Further off it rounds like [untilLabel].
  static String countdownLabel(Duration remaining) {
    if (remaining <= Duration.zero) {
      return 'now';
    }
    if (remaining.inDays >= 14) {
      return untilLabel(remaining);
    }
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    if (remaining.inDays >= 1) {
      final days = remaining.inDays == 1 ? '1 day' : '${remaining.inDays} days';
      return hours == 0 ? 'in $days' : 'in $days $hours h';
    }
    if (remaining.inHours >= 1) {
      return minutes == 0 ? 'in $hours h' : 'in $hours h $minutes min';
    }
    return remaining.inMinutes < 1 ? 'in under a minute' : 'in $minutes min';
  }

  /// The next time milestone, or null once every one is reached.
  static ProgressMilestone? nextMilestone(Duration smokeFreeDuration) {
    for (final milestone in timeMilestones) {
      if (smokeFreeDuration < milestone.duration) {
        return milestone;
      }
    }
    return null;
  }

  /// The latest time milestone reached, or the first one before any is.
  static ProgressMilestone currentMilestone(Duration smokeFreeDuration) {
    ProgressMilestone current = timeMilestones.first;
    for (final milestone in timeMilestones) {
      if (smokeFreeDuration >= milestone.duration) {
        current = milestone;
      } else {
        break;
      }
    }
    return current;
  }

  static ProgressMilestone? previousMilestone(ProgressMilestone milestone) {
    final index = timeMilestones.indexWhere(
      (item) => item.key == milestone.key,
    );
    if (index <= 0) {
      return null;
    }
    return timeMilestones[index - 1];
  }

  /// Every milestone the stats satisfy right now.
  static Set<String> unlockedKeys(MilestoneStats stats) {
    return {
      for (final milestone in milestones)
        if (milestone.isUnlocked(stats)) milestone.key,
    };
  }

  /// The stored keys as current ones, so milestones saved by earlier versions
  /// are not celebrated again.
  static Set<String> normalizeStoredKeys(Iterable<String> stored) {
    return {
      for (final key in stored)
        key.startsWith(legacyKeyPrefix)
            ? key.substring(legacyKeyPrefix.length)
            : key,
    };
  }
}

class ProgressMilestone {
  const ProgressMilestone({
    required this.key,
    required this.title,
    required this.body,
    this.name,
    this.duration = Duration.zero,
    this.badgeAsset,
    this.cravingsBeatenTarget,
    this.cigarettesAvoidedTarget,
    this.packsTarget,
    this.sealedDaysTarget,
    this.comeback = false,
  });

  final String key;

  /// For a time milestone, its length ("1 week"); for an earned one, its name.
  final String title;

  /// The badge name of a time milestone ("Week Warrior").
  final String? name;
  final String body;

  /// How long smoke-free a time milestone takes. Zero for earned ones.
  final Duration duration;
  final String? badgeAsset;
  final int? cravingsBeatenTarget;
  final int? cigarettesAvoidedTarget;
  final int? packsTarget;
  final int? sealedDaysTarget;

  /// Earned by beating a craving after a slip.
  final bool comeback;

  MilestoneKind get kind =>
      duration > Duration.zero ? MilestoneKind.time : MilestoneKind.earned;

  /// What is being counted and how far it has to go.
  ({double value, double target}) _measure(MilestoneStats stats) {
    if (duration > Duration.zero) {
      return (
        value: stats.smokeFreeDuration.inSeconds.toDouble(),
        target: duration.inSeconds.toDouble(),
      );
    }
    final cravings = cravingsBeatenTarget;
    if (cravings != null) {
      return (value: stats.cravingsBeaten.toDouble(), target: cravings * 1.0);
    }
    final avoided = cigarettesAvoidedTarget;
    if (avoided != null) {
      return (value: stats.cigarettesAvoided.toDouble(), target: avoided * 1.0);
    }
    final packs = packsTarget;
    if (packs != null) {
      return (value: stats.packsAvoided, target: packs * 1.0);
    }
    final sealed = sealedDaysTarget;
    if (sealed != null) {
      return (value: stats.sealedDays.toDouble(), target: sealed * 1.0);
    }
    return (value: comeback && stats.comeback ? 1 : 0, target: 1);
  }

  bool isUnlocked(MilestoneStats stats) {
    final measure = _measure(stats);
    return measure.value >= measure.target;
  }

  /// 0 to 1.
  double progress(MilestoneStats stats) {
    final measure = _measure(stats);
    if (measure.target <= 0) {
      return 1;
    }
    return (measure.value / measure.target).clamp(0.0, 1.0);
  }

  /// How far along a locked milestone is: "in 2 days", "7 of 10". Null when
  /// there is nothing to count, as with [comeback].
  String? progressLabel(MilestoneStats stats) {
    if (duration > Duration.zero) {
      return ProgressCalculations.untilLabel(
        duration - stats.smokeFreeDuration,
      );
    }
    if (comeback) {
      return null;
    }
    final measure = _measure(stats);
    final value = measure.value.floor().clamp(0, measure.target.floor());
    return '$value of ${measure.target.floor()}';
  }
}
