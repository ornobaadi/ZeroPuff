import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'smoking_log_repository_stub.dart'
    if (dart.library.io) 'smoking_log_repository_io.dart';

final smokingLogRepositoryProvider = Provider<SmokingLogRepository>((ref) {
  return getSmokingLogRepository(ref);
});

abstract class SmokingLogRepository {
  Future<String> addLog({
    required int count,
    required String trigger,
    DateTime? smokedAt,
    String? note,
  });
  Future<int> getTotalSmokedToday();
  Future<DateTime?> getLatestSmokedAt();
  Future<List<SmokingLogRecord>> getRecent({int limit = 90});
  Future<SmokingLogRecord?> getById(String logId);
  Future<void> updateLog({
    required String logId,
    required int count,
    required String trigger,
    required DateTime smokedAt,
    String? note,
  });
}

class SmokingLogRecord {
  const SmokingLogRecord({
    required this.logId,
    required this.count,
    required this.trigger,
    required this.smokedAt,
    this.note,
  });

  final String logId;
  final int count;
  final String trigger;
  final DateTime smokedAt;
  final String? note;
}
