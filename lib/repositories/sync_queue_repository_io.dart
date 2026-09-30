import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return SyncQueueRepository(database);
});

class SyncQueueRepository {
  const SyncQueueRepository(this._database);

  static const maxAttempts = 8;

  final Isar _database;

  Future<List<SyncQueueItem>> pending({int limit = 25}) {
    // Items that keep failing are skipped so one poison item cannot block the
    // whole queue forever.
    return _database.syncQueueItems
        .filter()
        .attemptCountLessThan(maxAttempts)
        .sortByCreatedAt()
        .limit(limit)
        .findAll();
  }

  Future<void> remove(int id) async {
    await _database.writeTxn(() => _database.syncQueueItems.delete(id));
  }

  Future<void> markFailed(SyncQueueItem item, Object error) async {
    item
      ..attemptCount += 1
      ..lastError = error.toString().split('
').first;
    await _database.writeTxn(() => _database.syncQueueItems.put(item));
  }
}
