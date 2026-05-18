import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';
import 'daily_checkin_repository.dart';

DailyCheckInRepository getDailyCheckInRepository(Ref ref) {
  final db = ref.watch(localDatabaseProvider);
  if (db == null) {
    throw StateError('Local database has not been initialized.');
  }
  return DailyCheckInRepositoryIO(db);
}

class DailyCheckInRepositoryIO implements DailyCheckInRepository {
  DailyCheckInRepositoryIO(this._isar);

  final Isar _isar;

  @override
  Future<DailyCheckInRecord?> getToday() async {
    final localDate = localDateKey(DateTime.now());
    final row = await _isar.dailyCheckIns.getByLocalDate(localDate);
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<List<DailyCheckInRecord>> getRecent({int limit = 14}) async {
    final rows = await _isar.dailyCheckIns
        .where()
        .sortByLocalDateDesc()
        .limit(limit)
        .findAll();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<DailyCheckInRecord> saveToday({
    required int mood,
    required bool smokeFreeToday,
    required int cigarettesSmoked,
    String? note,
  }) async {
    final now = DateTime.now();
    final localDate = localDateKey(now);
    final existing = await _isar.dailyCheckIns.getByLocalDate(localDate);
    final row = existing ?? DailyCheckIn()
      ..checkInId = const Uuid().v4();

    row
      ..localDate = localDate
      ..mood = mood
      ..smokeFreeToday = smokeFreeToday
      ..cigarettesSmoked = cigarettesSmoked
      ..note = note
      ..createdAt = now.toUtc()
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'daily_checkin'
      ..entityId = row.checkInId
      ..operation = 'upsert'
      ..createdAt = now;

    await _isar.writeTxn(() async {
      await _isar.dailyCheckIns.putByLocalDate(row);
      await _isar.syncQueueItems.put(queueItem);
    });

    return _toRecord(row);
  }

  DailyCheckInRecord _toRecord(DailyCheckIn row) {
    return DailyCheckInRecord(
      checkInId: row.checkInId,
      localDate: row.localDate,
      mood: row.mood,
      smokeFreeToday: row.smokeFreeToday,
      cigarettesSmoked: row.cigarettesSmoked,
      note: row.note,
      createdAt: row.createdAt.toLocal(),
    );
  }
}
