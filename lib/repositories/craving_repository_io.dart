import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/craving_rescue_data.dart';
import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';

final cravingRepositoryProvider = Provider<CravingRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return CravingRepository(database);
});

class CravingRepository {
  CravingRepository(this._database);

  final Isar _database;
  final Uuid _uuid = const Uuid();

  Future<String> startRescue({
    required int intensity,
    required List<String> triggers,
  }) async {
    final sessionId = _uuid.v7();
    final session = CravingRescueSession()
      ..sessionId = sessionId
      ..startedAt = DateTime.now()
      ..intensity = intensity
      ..triggers = triggers
      ..outcome = 'unknown'
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'craving_log'
      ..entityId = sessionId
      ..operation = 'upsert'
      ..createdAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.cravingRescueSessions.put(session);
      await _database.syncQueueItems.put(queueItem);
    });
    return sessionId;
  }

  Future<void> completeRescue({
    required String sessionId,
    required String outcome,
  }) async {
    final session = await _database.cravingRescueSessions
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
    if (session == null) {
      return;
    }

    session
      ..completedAt = DateTime.now()
      ..outcome = outcome
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'craving_log'
      ..entityId = sessionId
      ..operation = 'upsert'
      ..createdAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.cravingRescueSessions.put(session);
      await _database.syncQueueItems.put(queueItem);
    });
  }

  Future<List<CravingRescueData>> recent({int limit = 20}) async {
    final sessions = await _database.cravingRescueSessions
        .where()
        .sortByStartedAtDesc()
        .limit(limit)
        .findAll();
    return sessions
        .map(
          (session) => CravingRescueData(
            sessionId: session.sessionId,
            startedAt: session.startedAt,
            completedAt: session.completedAt,
            intensity: session.intensity,
            triggers: session.triggers,
            outcome: session.outcome,
          ),
        )
        .toList();
  }
}
