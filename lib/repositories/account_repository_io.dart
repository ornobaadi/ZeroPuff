import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return AccountRepository(database);
});

class AccountRepository {
  AccountRepository(this._database);

  final Isar _database;

  Future<void> deleteLocalData() async {
    await _database.writeTxn(() async {
      await _database.localProfiles.clear();
      await _database.onboardingDrafts.clear();
      await _database.cravingRescueSessions.clear();
      await _database.smokingLogs.clear();
      await _database.dailyCheckIns.clear();
      await _database.achievementStates.clear();
      await _database.notificationPreferences.clear();
      await _database.syncQueueItems.clear();
      await _database.localAppEvents.clear();
    });
  }
}
