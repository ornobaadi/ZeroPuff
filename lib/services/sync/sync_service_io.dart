import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/local_models.dart';
import '../../repositories/sync_queue_repository_io.dart';
import '../local_database/local_database_service_io.dart';
import '../supabase/supabase_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return SyncService(
    database: database,
    client: ref.watch(supabaseClientProvider),
    queue: ref.watch(syncQueueRepositoryProvider),
  );
});

final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    return 0;
  }
  return database.syncQueueItems.count();
});

class SyncService {
  const SyncService({
    required Isar database,
    required SupabaseClient? client,
    required SyncQueueRepository queue,
  }) : _database = database,
       _client = client,
       _queue = queue;

  final Isar _database;
  final SupabaseClient? _client;
  final SyncQueueRepository _queue;

  Future<SyncRunResult> syncPending({int limit = 25}) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      final remaining = await _database.syncQueueItems.count();
      return SyncRunResult(skipped: true, remaining: remaining);
    }

    final items = await _queue.pending(limit: limit);
    var succeeded = 0;
    var failed = 0;

    for (final item in items) {
      try {
        await _syncItem(client, user.id, item);
        await _queue.remove(item.id);
        succeeded += 1;
      } on Object catch (error) {
        await _queue.markFailed(item, error);
        failed += 1;
      }
    }

    final remaining = await _database.syncQueueItems.count();
    return SyncRunResult(
      attempted: items.length,
      succeeded: succeeded,
      failed: failed,
      remaining: remaining,
    );
  }

  Future<void> _syncItem(
    SupabaseClient client,
    String userId,
    SyncQueueItem item,
  ) async {
    switch (item.entityType) {
      case 'profile':
        await _syncProfile(client, userId, item.entityId);
      case 'craving_log':
        await _syncCravingLog(client, userId, item.entityId);
      case 'smoking_log':
        await _syncSmokingLog(client, userId, item.entityId);
      case 'daily_checkin':
        await _syncDailyCheckIn(client, userId, item.entityId);
      case 'achievement':
        await _syncAchievement(client, userId, item.entityId);
      case 'notification_preferences':
        await _syncNotificationPreferences(client, userId);
      case 'app_event':
        await _syncAppEvent(client, userId, item.entityId);
      default:
        throw StateError('Unsupported sync entity: ${item.entityType}');
    }
  }

  Future<void> _syncProfile(
    SupabaseClient client,
    String userId,
    String entityId,
  ) async {
    final profile = await _database.localProfiles
        .filter()
        .userIdEqualTo(entityId)
        .findFirst();
    if (profile == null) {
      return;
    }

    final remoteId = profile.userId == 'guest-device' ? userId : profile.userId;
    await client.from('profiles').upsert({
      'id': remoteId,
      'display_name': profile.displayName,
      'avatar_url': profile.avatarUrl,
      'quit_date': profile.quitDate.toUtc().toIso8601String(),
      'cigarettes_per_day': profile.cigarettesPerDay,
      'pack_price': profile.packPrice,
      'pack_size': profile.packSize,
      'currency_code': profile.currencyCode,
      'currency_symbol': profile.currencySymbol,
      'triggers': profile.triggers,
      'quit_reason': profile.quitReason,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    profile.synced = true;
    await _database.writeTxn(() => _database.localProfiles.put(profile));
  }

  Future<void> _syncCravingLog(
    SupabaseClient client,
    String userId,
    String sessionId,
  ) async {
    final session = await _database.cravingRescueSessions
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
    if (session == null) {
      return;
    }

    await client.from('craving_logs').upsert({
      'id': session.sessionId,
      'user_id': userId,
      'intensity': session.intensity,
      'triggers': session.triggers,
      'started_at': session.startedAt.toUtc().toIso8601String(),
      'completed_at': session.completedAt?.toUtc().toIso8601String(),
      'outcome': session.outcome,
      'created_at': session.startedAt.toUtc().toIso8601String(),
    });

    session.synced = true;
    await _database.writeTxn(
      () => _database.cravingRescueSessions.put(session),
    );
  }

  Future<void> _syncSmokingLog(
    SupabaseClient client,
    String userId,
    String logId,
  ) async {
    final log = await _database.smokingLogs
        .filter()
        .logIdEqualTo(logId)
        .findFirst();
    if (log == null) {
      return;
    }

    await client.from('smoking_logs').upsert({
      'id': log.logId,
      'user_id': userId,
      'smoked_at': log.smokedAt.toUtc().toIso8601String(),
      'count': log.count,
      'trigger': log.trigger,
      'note': log.note,
      'created_at': log.smokedAt.toUtc().toIso8601String(),
    });

    log.synced = true;
    await _database.writeTxn(() => _database.smokingLogs.put(log));
  }

  Future<void> _syncDailyCheckIn(
    SupabaseClient client,
    String userId,
    String checkInId,
  ) async {
    final checkIn = await _database.dailyCheckIns
        .filter()
        .checkInIdEqualTo(checkInId)
        .findFirst();
    if (checkIn == null) {
      return;
    }

    await client.from('daily_checkins').upsert({
      'id': checkIn.checkInId,
      'user_id': userId,
      'local_date': checkIn.localDate,
      'mood': checkIn.mood,
      'smoke_free_today': checkIn.smokeFreeToday,
      'cigarettes_smoked': checkIn.cigarettesSmoked,
      'note': checkIn.note,
      'created_at': checkIn.createdAt.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    checkIn.synced = true;
    await _database.writeTxn(() => _database.dailyCheckIns.put(checkIn));
  }

  Future<void> _syncAchievement(
    SupabaseClient client,
    String userId,
    String achievementKey,
  ) async {
    final achievement = await _database.achievementStates
        .filter()
        .achievementKeyEqualTo(achievementKey)
        .findFirst();
    if (achievement == null) {
      return;
    }

    await client.from('achievements').upsert({
      'user_id': userId,
      'achievement_key': achievement.achievementKey,
      'unlocked_at': achievement.unlockedAt?.toUtc().toIso8601String(),
    }, onConflict: 'user_id,achievement_key');

    achievement.synced = true;
    await _database.writeTxn(
      () => _database.achievementStates.put(achievement),
    );
  }

  Future<void> _syncNotificationPreferences(
    SupabaseClient client,
    String userId,
  ) async {
    final preferences = await _database.notificationPreferences
        .where()
        .findFirst();
    if (preferences == null) {
      return;
    }

    await client.from('notification_preferences').upsert({
      'user_id': userId,
      'daily_checkin_enabled': preferences.dailyCheckInEnabled,
      'daily_checkin_time':
          '${_two(preferences.dailyCheckInHour)}:${_two(preferences.dailyCheckInMinute)}:00',
      'milestone_reminder_enabled': preferences.milestoneReminderEnabled,
      'streak_protection_enabled': preferences.streakProtectionEnabled,
      'updated_at': preferences.updatedAt.toUtc().toIso8601String(),
    });

    preferences.synced = true;
    await _database.writeTxn(
      () => _database.notificationPreferences.put(preferences),
    );
  }

  Future<void> _syncAppEvent(
    SupabaseClient client,
    String userId,
    String eventId,
  ) async {
    final event = await _database.localAppEvents
        .filter()
        .eventIdEqualTo(eventId)
        .findFirst();
    if (event == null) {
      return;
    }

    await client.from('app_events').upsert({
      'id': event.eventId,
      'user_id': userId,
      'event_name': event.eventName,
      'properties': jsonDecode(event.propertiesJson),
      'created_at': event.createdAt.toUtc().toIso8601String(),
    });

    event.synced = true;
    await _database.writeTxn(() => _database.localAppEvents.put(event));
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class SyncRunResult {
  const SyncRunResult({
    this.attempted = 0,
    this.succeeded = 0,
    this.failed = 0,
    this.remaining = 0,
    this.skipped = false,
  });

  final int attempted;
  final int succeeded;
  final int failed;
  final int remaining;
  final bool skipped;
}
