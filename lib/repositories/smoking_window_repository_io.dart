import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../models/smoking_window_data.dart';
import '../services/local_database/local_database_service_io.dart';
import 'smoking_window_repository.dart';

SmokingWindowRepository getSmokingWindowRepository(Ref ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return SmokingWindowRepositoryIo(database);
}

class SmokingWindowRepositoryIo implements SmokingWindowRepository {
  const SmokingWindowRepositoryIo(this._database);

  final Isar _database;

  @override
  Future<SmokingWindowData> loadPrimary() async {
    final row = await _database.localSmokingWindows
        .filter()
        .isPrimaryEqualTo(true)
        .findFirst();
    if (row == null) {
      return SmokingWindowData.defaultWindow();
    }
    return SmokingWindowData(
      windowId: row.windowId,
      label: row.label,
      startMinutes: row.startMinutes,
      endMinutes: row.endMinutes,
      daysOfWeek: row.daysOfWeek,
      enabled: row.enabled,
      isPrimary: row.isPrimary,
      source: row.source,
    );
  }

  @override
  Future<void> savePrimary({
    required String userId,
    required SmokingWindowData window,
  }) async {
    final now = DateTime.now();
    final row =
        await _database.localSmokingWindows.getByWindowId(
          SmokingWindowData.primaryWindowId,
        ) ??
        LocalSmokingWindow();
    row
      ..windowId = SmokingWindowData.primaryWindowId
      ..userId = userId
      ..label = window.label
      ..startMinutes = window.startMinutes
      ..endMinutes = window.endMinutes
      ..daysOfWeek = window.daysOfWeek
      ..enabled = window.enabled
      ..isPrimary = true
      ..source = window.source
      ..updatedAt = now
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'smoking_window'
      ..entityId = row.windowId
      ..operation = 'upsert'
      ..createdAt = now;

    await _database.writeTxn(() async {
      await _database.localSmokingWindows.putByWindowId(row);
      await _database.syncQueueItems.put(queueItem);
    });
  }

  @override
  Future<List<SmokingWindowData>> loadRituals() async {
    final rows = await _database.localSmokingWindows
        .filter()
        .isPrimaryEqualTo(false)
        .sortByStartMinutes()
        .findAll();
    return rows
        .map(
          (row) => SmokingWindowData(
            windowId: row.windowId,
            label: row.label,
            startMinutes: row.startMinutes,
            endMinutes: row.endMinutes,
            daysOfWeek: row.daysOfWeek,
            enabled: row.enabled,
            isPrimary: false,
            source: row.source,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveRitual({
    required String userId,
    required SmokingWindowData ritual,
  }) async {
    final now = DateTime.now();
    final row =
        await _database.localSmokingWindows.getByWindowId(ritual.windowId) ??
        LocalSmokingWindow();
    row
      ..windowId = ritual.windowId
      ..userId = userId
      ..label = ritual.label
      ..startMinutes = ritual.startMinutes
      ..endMinutes = ritual.endMinutes
      ..daysOfWeek = ritual.daysOfWeek
      ..enabled = ritual.enabled
      ..isPrimary = false
      ..source = ritual.source
      ..updatedAt = now
      ..synced = false;

    await _database.writeTxn(() async {
      await _database.localSmokingWindows.putByWindowId(row);
      await _database.syncQueueItems.put(_queueItem(ritual.windowId, now));
    });
  }

  @override
  Future<void> deleteRitual(String windowId) async {
    if (windowId == SmokingWindowData.primaryWindowId) {
      return;
    }
    // Sync sees the row is gone and removes it from the account too.
    await _database.writeTxn(() async {
      await _database.localSmokingWindows.deleteByWindowId(windowId);
      await _database.syncQueueItems.put(
        _queueItem(windowId, DateTime.now()),
      );
    });
  }

  SyncQueueItem _queueItem(String windowId, DateTime at) {
    return SyncQueueItem()
      ..entityType = 'smoking_window'
      ..entityId = windowId
      ..operation = 'upsert'
      ..createdAt = at;
  }
}
