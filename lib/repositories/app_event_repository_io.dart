import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/app_event.dart';
import '../models/local_models.dart';
import '../services/local_database/local_database_service_io.dart';

final appEventRepositoryProvider = Provider<AppEventRepository>((ref) {
  final database = ref.watch(localDatabaseProvider);
  if (database == null) {
    throw StateError('Local database has not been initialized.');
  }
  return AppEventRepository(database);
});

class AppEventRepository {
  AppEventRepository(this._database);

  final Isar _database;
  final Uuid _uuid = const Uuid();

  Future<void> track(AppEvent event) async {
    final eventId = _uuid.v7();
    final now = event.createdAt ?? DateTime.now();

    final localEvent = LocalAppEvent()
      ..eventId = eventId
      ..eventName = event.eventName
      ..propertiesJson = jsonEncode(event.properties)
      ..createdAt = now
      ..synced = false;

    final queueItem = SyncQueueItem()
      ..entityType = 'app_event'
      ..entityId = eventId
      ..operation = 'insert'
      ..createdAt = now;

    await _database.writeTxn(() async {
      await _database.localAppEvents.put(localEvent);
      await _database.syncQueueItems.put(queueItem);
    });
  }
}
