import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      return NotificationPreferencesRepository();
    });

class NotificationPreferencesRepository {
  NotificationPreferences _preferences = const NotificationPreferences();

  Future<NotificationPreferences> load() async => _preferences;

  Future<NotificationPreferences> save(
    NotificationPreferences preferences,
  ) async {
    _preferences = preferences;
    return _preferences;
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    this.dailyCheckInEnabled = true,
    this.dailyCheckInHour = 20,
    this.dailyCheckInMinute = 30,
    this.milestoneReminderEnabled = true,
    this.streakProtectionEnabled = true,
    this.dangerWindowEnabled = true,
  });

  final bool dailyCheckInEnabled;
  final int dailyCheckInHour;
  final int dailyCheckInMinute;
  final bool milestoneReminderEnabled;
  final bool streakProtectionEnabled;
  final bool dangerWindowEnabled;

  NotificationPreferences copyWith({
    bool? dailyCheckInEnabled,
    int? dailyCheckInHour,
    int? dailyCheckInMinute,
    bool? milestoneReminderEnabled,
    bool? streakProtectionEnabled,
    bool? dangerWindowEnabled,
  }) {
    return NotificationPreferences(
      dailyCheckInEnabled: dailyCheckInEnabled ?? this.dailyCheckInEnabled,
      dailyCheckInHour: dailyCheckInHour ?? this.dailyCheckInHour,
      dailyCheckInMinute: dailyCheckInMinute ?? this.dailyCheckInMinute,
      milestoneReminderEnabled:
          milestoneReminderEnabled ?? this.milestoneReminderEnabled,
      streakProtectionEnabled:
          streakProtectionEnabled ?? this.streakProtectionEnabled,
      dangerWindowEnabled: dangerWindowEnabled ?? this.dangerWindowEnabled,
    );
  }
}
