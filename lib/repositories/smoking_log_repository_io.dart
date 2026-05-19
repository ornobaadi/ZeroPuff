import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';
import 'smoking_log_repository.dart';

SmokingLogRepository getSmokingLogRepository(Ref ref) {
  final db = ref.watch(localDatabaseProvider);
  if (db == null) {
    throw StateError('Local database has not been initialized.');
  }
  return SmokingLogRepositoryIO(db);
}

class SmokingLogRepositoryIO implements SmokingLogRepository {
  SmokingLogRepositoryIO(this._isar);

  final Isar _isar;

  @override
  Future<String> addLog({
    required int count,
    required String trigger,
    DateTime? smokedAt,
    String? note,
  }) async {
    final logId = const Uuid().v4();
    final log = SmokingLog()
      ..logId = logId
      ..smokedAt = (smokedAt ?? DateTime.now()).toUtc()
      ..count = count
      ..trigger = trigger
      ..note = note
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'smoking_log'
      ..entityId = logId
      ..operation = 'upsert'
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.smokingLogs.put(log);
      await _isar.syncQueueItems.put(queueItem);
    });

    return logId;
  }

  @override
  Future<int> getTotalSmokedToday() async {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final logs = await _isar.smokingLogs
        .filter()
        .smokedAtBetween(startOfDay, endOfDay)
        .findAll();

    return logs.fold<int>(0, (sum, log) => sum + log.count);
  }

  @override
  Future<DateTime?> getLatestSmokedAt() async {
    final logs = await _isar.smokingLogs
        .where()
        .sortBySmokedAtDesc()
        .limit(1)
        .findAll();
    if (logs.isEmpty) {
      return null;
    }
    return logs.first.smokedAt.toLocal();
  }

  @override
  Future<List<SmokingLogRecord>> getRecent({int limit = 90}) async {
    final logs = await _isar.smokingLogs
        .where()
        .sortBySmokedAtDesc()
        .limit(limit)
        .findAll();
    return logs
        .map(
          (log) => SmokingLogRecord(
            logId: log.logId,
            count: log.count,
            trigger: log.trigger,
            smokedAt: log.smokedAt.toLocal(),
            note: log.note,
          ),
        )
        .toList();
  }
}
