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
    String? note,
  }) async {
    final logId = const Uuid().v4();
    final log = SmokingLog()
      ..logId = logId
      ..smokedAt = DateTime.now().toUtc()
      ..count = count
      ..trigger = trigger
      ..note = note;

    await _isar.writeTxn(() async {
      await _isar.smokingLogs.put(log);
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
}
