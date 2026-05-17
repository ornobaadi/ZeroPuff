import 'package:isar_community/isar.dart';

part 'local_models.g.dart';

@collection
class LocalProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  late String displayName;
  String? avatarUrl;
  late DateTime quitDate;
  late int cigarettesPerDay;
  late double packPrice;
  late int packSize;
  late List<String> triggers;
  String? quitReason;
  late DateTime updatedAt;
  bool synced = false;
}

@collection
class OnboardingDraft {
  Id id = Isar.autoIncrement;

  DateTime? quitDate;
  int? cigarettesPerDay;
  double? packPrice;
  int? packSize;
  List<String> triggers = [];
  String? quitReason;
  int currentStep = 0;
  bool completed = false;
  late DateTime updatedAt;
}

@collection
class CravingRescueSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  late DateTime startedAt;
  DateTime? completedAt;
  int intensity = 5;
  late List<String> triggers;
  String outcome = 'unknown';
  bool synced = false;
}

@collection
class SmokingLog {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String logId;

  late DateTime smokedAt;
  int count = 1;
  String trigger = 'other';
  String? note;
  bool synced = false;
}

@collection
class DailyCheckIn {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String checkInId;

  @Index(unique: true, replace: true)
  late String localDate;

  int mood = 3;
  bool smokeFreeToday = true;
  int cigarettesSmoked = 0;
  String? note;
  late DateTime createdAt;
  bool synced = false;
}

@collection
class AchievementState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String achievementKey;

  bool unlocked = false;
  DateTime? unlockedAt;
  bool synced = false;
}

@collection
class NotificationPreference {
  Id id = Isar.autoIncrement;

  bool dailyCheckInEnabled = true;
  int dailyCheckInHour = 21;
  int dailyCheckInMinute = 0;
  bool milestoneReminderEnabled = true;
  bool streakProtectionEnabled = true;
  late DateTime updatedAt;
  bool synced = false;
}

@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String entityType;

  late String entityId;
  String operation = 'upsert';
  late DateTime createdAt;
  int attemptCount = 0;
  String? lastError;
}
