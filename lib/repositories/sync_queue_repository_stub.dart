import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

class SyncQueueRepository {
  Future<List<Object>> pending({int limit = 25}) async => [];

  Future<void> remove(int id) async {}

  Future<void> markFailed(Object item, Object error) async {}
}
