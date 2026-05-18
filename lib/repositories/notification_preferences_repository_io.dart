import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      final database = ref.watch(localDatabaseProvider);
      if (database == null) {
        throw StateError('Local database has not been initialized.');
      }
      return NotificationPreferencesRepository(database);
    });

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._database);

  final Isar _database;

  Future<NotificationPreferences> load() async {
    final row = await _database.notificationPreferences.where().findFirst();
    if (row == null) {
      return const NotificationPreferences();
    }

    return NotificationPreferences(
      dailyCheckInEnabled: row.dailyCheckInEnabled,
      dailyCheckInHour: row.dailyCheckInHour,
      dailyCheckInMinute: row.dailyCheckInMinute,
      milestoneReminderEnabled: row.milestoneReminderEnabled,
      streakProtectionEnabled: row.streakProtectionEnabled,
    );
  }

  Future<NotificationPreferences> save(
    NotificationPreferences preferences,
  ) async {
    final existing = await _database.notificationPreferences
        .where()
        .findFirst();
    final row = existing ?? NotificationPreference();
    final now = DateTime.now();

    row
      ..dailyCheckInEnabled = preferences.dailyCheckInEnabled
      ..dailyCheckInHour = preferences.dailyCheckInHour
      ..dailyCheckInMinute = preferences.dailyCheckInMinute
      ..milestoneReminderEnabled = preferences.milestoneReminderEnabled
      ..streakProtectionEnabled = preferences.streakProtectionEnabled
      ..updatedAt = now
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'notification_preferences'
      ..entityId = 'local'
      ..operation = 'upsert'
      ..createdAt = now;

    await _database.writeTxn(() async {
      await _database.notificationPreferences.put(row);
      await _database.syncQueueItems.put(queueItem);
    });

    return preferences;
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
