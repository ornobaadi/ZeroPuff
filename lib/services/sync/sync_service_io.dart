import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/local_models.dart';
import '../../models/smoking_window_data.dart';
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

  Future<RemoteRestoreResult> restoreRemoteSnapshot({
    bool replaceLocal = true,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return const RemoteRestoreResult(skipped: true);
    }

    final profileRows = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .limit(1);
    final cravingRows = await client
        .from('craving_logs')
        .select()
        .eq('user_id', user.id)
        .order('started_at', ascending: false)
        .limit(500);
    final smokingRows = await client
        .from('smoking_logs')
        .select()
        .eq('user_id', user.id)
        .order('smoked_at', ascending: false)
        .limit(500);
    final checkInRows = await client
        .from('daily_checkins')
        .select()
        .eq('user_id', user.id)
        .order('local_date', ascending: false)
        .limit(500);
    final achievementRows = await client
        .from('achievements')
        .select()
        .eq('user_id', user.id)
        .limit(500);
    final preferenceRows = await client
        .from('notification_preferences')
        .select()
        .eq('user_id', user.id)
        .limit(1);
    final smokingWindowRows = await client
        .from('user_smoking_windows')
        .select()
        .eq('user_id', user.id)
        .order('is_primary', ascending: false)
        .limit(10);

    final profiles = _rows(profileRows);
    final cravings = _rows(cravingRows);
    final smokingLogs = _rows(smokingRows);
    final checkIns = _rows(checkInRows);
    final achievements = _rows(achievementRows);
    final preferences = _rows(preferenceRows);
    final smokingWindows = _rows(smokingWindowRows);

    await _database.writeTxn(() async {
      if (replaceLocal) {
        await _database.localProfiles.clear();
        await _database.cravingRescueSessions.clear();
        await _database.smokingLogs.clear();
        await _database.dailyCheckIns.clear();
        await _database.achievementStates.clear();
        await _database.notificationPreferences.clear();
        await _database.localSmokingWindows.clear();
      }

      for (final row in profiles) {
        final quitDate = _dateTime(row['quit_date']) ?? DateTime.now();
        final profile = LocalProfile()
          ..userId = user.id
          ..displayName = row['display_name']?.toString() ?? ''
          ..avatarUrl = row['avatar_url']?.toString()
          ..quitDate = quitDate
          ..cigarettesPerDay = _int(row['cigarettes_per_day'])
          ..packPrice = _double(row['pack_price'])
          ..packSize = _int(row['pack_size'], fallback: 20)
          ..currencyCode = row['currency_code']?.toString() ?? 'USD'
          ..currencySymbol = row['currency_symbol']?.toString() ?? r'$'
          ..triggers = _stringList(row['triggers'])
          ..quitReason = row['quit_reason']?.toString()
          ..updatedAt = _dateTime(row['updated_at']) ?? DateTime.now()
          ..synced = true;
        await _database.localProfiles.putByUserId(profile);
      }

      for (final row in cravings) {
        final sessionId = row['id']?.toString();
        final startedAt = _dateTime(row['started_at']);
        if (sessionId == null || startedAt == null) {
          continue;
        }
        final session = CravingRescueSession()
          ..sessionId = sessionId
          ..startedAt = startedAt
          ..completedAt = _dateTime(row['completed_at'])
          ..intensity = _int(row['intensity'], fallback: 5)
          ..triggers = _stringList(row['triggers'])
          ..outcome = row['outcome']?.toString() ?? 'unknown'
          ..synced = true;
        await _database.cravingRescueSessions.putBySessionId(session);
      }

      for (final row in smokingLogs) {
        final logId = row['id']?.toString();
        final smokedAt = _dateTime(row['smoked_at']);
        if (logId == null || smokedAt == null) {
          continue;
        }
        final log = SmokingLog()
          ..logId = logId
          ..smokedAt = smokedAt
          ..count = _int(row['count'], fallback: 1)
          ..trigger = row['trigger']?.toString() ?? 'other'
          ..note = row['note']?.toString()
          ..synced = true;
        await _database.smokingLogs.putByLogId(log);
      }

      for (final row in checkIns) {
        final checkInId = row['id']?.toString();
        final localDate = row['local_date']?.toString();
        if (checkInId == null || localDate == null) {
          continue;
        }
        final checkIn = DailyCheckIn()
          ..checkInId = checkInId
          ..localDate = localDate
          ..mood = _int(row['mood'], fallback: 3)
          ..smokeFreeToday = row['smoke_free_today'] == true
          ..cigarettesSmoked = _int(row['cigarettes_smoked'])
          ..note = row['note']?.toString()
          ..createdAt = _dateTime(row['created_at']) ?? DateTime.now()
          ..synced = true;
        await _database.dailyCheckIns.putByCheckInId(checkIn);
      }

      for (final row in achievements) {
        final key = row['achievement_key']?.toString();
        if (key == null || key.isEmpty) {
          continue;
        }
        final achievement = AchievementState()
          ..achievementKey = key
          ..unlocked = true
          ..unlockedAt = _dateTime(row['unlocked_at'])
          ..synced = true;
        await _database.achievementStates.putByAchievementKey(achievement);
      }

      for (final row in preferences) {
        final timeParts = (row['daily_checkin_time']?.toString() ?? '21:00')
            .split(':');
        final preferences = NotificationPreference()
          ..dailyCheckInEnabled = row['daily_checkin_enabled'] != false
          ..dailyCheckInHour = int.tryParse(timeParts.first) ?? 21
          ..dailyCheckInMinute = timeParts.length > 1
              ? int.tryParse(timeParts[1]) ?? 0
              : 0
          ..milestoneReminderEnabled =
              row['milestone_reminder_enabled'] != false
          ..streakProtectionEnabled = row['streak_protection_enabled'] != false
          ..dangerWindowEnabled = row['danger_window_enabled'] != false
          ..updatedAt = _dateTime(row['updated_at']) ?? DateTime.now()
          ..synced = true;
        await _database.notificationPreferences.put(preferences);
      }

      for (final row in smokingWindows) {
        final startMinutes = SmokingWindowData.minutesFromSql(
          row['start_time'],
        );
        final endMinutes = SmokingWindowData.minutesFromSql(row['end_time']);
        if (startMinutes == null || endMinutes == null) {
          continue;
        }
        final window = LocalSmokingWindow()
          ..windowId =
              row['id']?.toString() ?? SmokingWindowData.primaryWindowId
          ..userId = user.id
          ..label = row['label']?.toString() ?? 'usual'
          ..startMinutes = startMinutes
          ..endMinutes = endMinutes
          ..daysOfWeek = _intList(row['days_of_week'])
          ..enabled = row['enabled'] != false
          ..isPrimary = row['is_primary'] != false
          ..source = row['source']?.toString() ?? 'onboarding'
          ..updatedAt = _dateTime(row['updated_at']) ?? DateTime.now()
          ..synced = true;
        if (window.isPrimary) {
          window.windowId = SmokingWindowData.primaryWindowId;
        }
        await _database.localSmokingWindows.putByWindowId(window);
      }
    });

    return RemoteRestoreResult(
      profiles: profiles.length,
      cravingLogs: cravings.length,
      smokingLogs: smokingLogs.length,
      dailyCheckIns: checkIns.length,
      achievements: achievements.length,
      notificationPreferences: preferences.length,
      smokingWindows: smokingWindows.length,
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
      case 'smoking_window':
        await _syncSmokingWindow(client, userId, item.entityId);
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
      'danger_window_enabled': preferences.dangerWindowEnabled,
      'updated_at': preferences.updatedAt.toUtc().toIso8601String(),
    });

    preferences.synced = true;
    await _database.writeTxn(
      () => _database.notificationPreferences.put(preferences),
    );
  }

  Future<void> _syncSmokingWindow(
    SupabaseClient client,
    String userId,
    String windowId,
  ) async {
    final window = await _database.localSmokingWindows
        .filter()
        .windowIdEqualTo(windowId)
        .findFirst();
    if (window == null) {
      return;
    }

    final existing = await client
        .from('user_smoking_windows')
        .select('id')
        .eq('user_id', userId)
        .eq('is_primary', true)
        .maybeSingle();
    final payload = {
      'user_id': userId,
      'label': window.label,
      'start_time': SmokingWindowData(
        startMinutes: window.startMinutes,
        endMinutes: window.endMinutes,
      ).startTimeSql,
      'end_time': SmokingWindowData(
        startMinutes: window.startMinutes,
        endMinutes: window.endMinutes,
      ).endTimeSql,
      'days_of_week': window.daysOfWeek,
      'enabled': window.enabled,
      'is_primary': true,
      'source': window.source,
      'updated_at': window.updatedAt.toUtc().toIso8601String(),
    };
    final remoteId = existing?['id']?.toString();
    if (remoteId == null) {
      await client.from('user_smoking_windows').insert(payload);
    } else {
      await client
          .from('user_smoking_windows')
          .update(payload)
          .eq('id', remoteId);
    }

    window
      ..userId = userId
      ..synced = true;
    await _database.writeTxn(
      () => _database.localSmokingWindows.putByWindowId(window),
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

  List<Map<String, dynamic>> _rows(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  DateTime? _dateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value.toLocal();
    }
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  int _int(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _double(Object? value, {double fallback = 0}) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  List<int> _intList(Object? value) {
    if (value is List) {
      return value.map(_int).where((item) => item >= 1 && item <= 7).toList();
    }
    return const [1, 2, 3, 4, 5, 6, 7];
  }
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

class RemoteRestoreResult {
  const RemoteRestoreResult({
    this.profiles = 0,
    this.cravingLogs = 0,
    this.smokingLogs = 0,
    this.dailyCheckIns = 0,
    this.achievements = 0,
    this.notificationPreferences = 0,
    this.smokingWindows = 0,
    this.skipped = false,
  });

  final int profiles;
  final int cravingLogs;
  final int smokingLogs;
  final int dailyCheckIns;
  final int achievements;
  final int notificationPreferences;
  final int smokingWindows;
  final bool skipped;

  int get restoredRows =>
      profiles +
      cravingLogs +
      smokingLogs +
      dailyCheckIns +
      achievements +
      notificationPreferences +
      smokingWindows;
}
