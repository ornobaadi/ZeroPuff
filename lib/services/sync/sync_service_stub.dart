import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

final pendingSyncCountProvider = FutureProvider<int>((ref) async => 0);

class SyncService {
  Future<SyncRunResult> syncPending({int limit = 25}) async {
    return const SyncRunResult(skipped: true);
  }

  Future<RemoteRestoreResult> restoreRemoteSnapshot({
    bool replaceLocal = true,
  }) async {
    return const RemoteRestoreResult(skipped: true);
  }
}

class SyncRunResult {
  const SyncRunResult({
    this.attempted = 0,
    this.succeeded = 0,
    this.failed = 0,
    this.remaining = 0,
    this.skipped = false,
  });

  final int attempted;
  final int succeeded;
  final int failed;
  final int remaining;
  final bool skipped;
}

class RemoteRestoreResult {
  const RemoteRestoreResult({this.restoredRows = 0, this.skipped = true});

  final int restoredRows;
  final bool skipped;
}
