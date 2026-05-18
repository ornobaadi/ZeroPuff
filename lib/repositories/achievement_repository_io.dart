import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';
import 'achievement_repository.dart';

AchievementRepository getAchievementRepository(Ref ref) {
  final db = ref.watch(localDatabaseProvider);
  if (db == null) {
    throw StateError('Local database has not been initialized.');
  }
  return AchievementRepositoryIO(db);
}

class AchievementRepositoryIO implements AchievementRepository {
  AchievementRepositoryIO(this._isar);

  final Isar _isar;

  @override
  Future<Set<String>> unlockedKeys() async {
    final rows = await _isar.achievementStates
        .filter()
        .unlockedEqualTo(true)
        .findAll();
    return rows.map((row) => row.achievementKey).toSet();
  }

  @override
  Future<void> unlockAll(Set<String> keys) async {
    if (keys.isEmpty) {
      return;
    }
    final existing = await unlockedKeys();
    final missing = keys.difference(existing);
    if (missing.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final states = missing.map((key) {
      return AchievementState()
        ..achievementKey = key
        ..unlocked = true
        ..unlockedAt = now.toUtc()
        ..synced = false;
    }).toList();
    final queueItems = missing.map((key) {
      return SyncQueueItem()
        ..entityType = 'achievement'
        ..entityId = key
        ..operation = 'upsert'
        ..createdAt = now;
    }).toList();

    await _isar.writeTxn(() async {
      await _isar.achievementStates.putAllByAchievementKey(states);
      await _isar.syncQueueItems.putAll(queueItems);
    });
  }
}
