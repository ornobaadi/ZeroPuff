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
    this.dailyCheckInHour = 21,
    this.dailyCheckInMinute = 0,
    this.milestoneReminderEnabled = true,
    this.streakProtectionEnabled = true,
  });

  final bool dailyCheckInEnabled;
  final int dailyCheckInHour;
  final int dailyCheckInMinute;
  final bool milestoneReminderEnabled;
  final bool streakProtectionEnabled;

  NotificationPreferences copyWith({
    bool? dailyCheckInEnabled,
    int? dailyCheckInHour,
    int? dailyCheckInMinute,
    bool? milestoneReminderEnabled,
    bool? streakProtectionEnabled,
  }) {
    return NotificationPreferences(
      dailyCheckInEnabled: dailyCheckInEnabled ?? this.dailyCheckInEnabled,
      dailyCheckInHour: dailyCheckInHour ?? this.dailyCheckInHour,
      dailyCheckInMinute: dailyCheckInMinute ?? this.dailyCheckInMinute,
      milestoneReminderEnabled:
          milestoneReminderEnabled ?? this.milestoneReminderEnabled,
      streakProtectionEnabled:
          streakProtectionEnabled ?? this.streakProtectionEnabled,
    );
  }
}
