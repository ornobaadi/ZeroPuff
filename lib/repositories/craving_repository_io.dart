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

  /// Opens a session the moment a rescue starts. Strength and triggers are
  /// filled in by [completeRescue], once the user has had a chance to breathe.
  Future<String> startRescue({
    int intensity = 6,
    List<String> triggers = const [],
  }) async {
    final sessionId = _uuid.v7();
    final session = CravingRescueSession()
      ..sessionId = sessionId
      ..startedAt = DateTime.now()
      ..intensity = intensity
      ..triggers = triggers
      ..outcome = 'unknown'
      ..synced = false;

    await _save(session);
    return sessionId;
  }

  Future<void> completeRescue({
    required String sessionId,
    required String outcome,
    int? intensity,
    int? intensityAfter,
    List<String>? triggers,
    List<String>? toolsUsed,
    int? breaths,
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
      ..intensity = intensity ?? session.intensity
      ..intensityAfter = intensityAfter ?? session.intensityAfter
      ..triggers = triggers ?? session.triggers
      ..toolsUsed = toolsUsed ?? session.toolsUsed
      ..breaths = breaths ?? session.breaths
      ..synced = false;

    await _save(session);
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
            intensityAfter: session.intensityAfter,
            toolsUsed: session.toolsUsed,
            breaths: session.breaths,
          ),
        )
        .toList();
  }

  /// How many cravings the user has got through, ever.
  Future<int> resistedCount() {
    return _database.cravingRescueSessions
        .filter()
        .outcomeEqualTo('resisted')
        .count();
  }

  Future<void> _save(CravingRescueSession session) async {
    final queueItem = SyncQueueItem()
      ..entityType = 'craving_log'
      ..entityId = session.sessionId
      ..operation = 'upsert'
      ..createdAt = DateTime.now();

    await _database.writeTxn(() async {
      await _database.cravingRescueSessions.put(session);
      await _database.syncQueueItems.put(queueItem);
    });
  }
}
