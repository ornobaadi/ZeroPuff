import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'smoking_log_repository.dart';

SmokingLogRepository getSmokingLogRepository(Ref ref) {
  return SmokingLogRepositoryStub();
}

class SmokingLogRepositoryStub implements SmokingLogRepository {
  static final List<_StubSmokingLog> _logs = [];

  @override
  Future<String> addLog({
    required int count,
    required String trigger,
    DateTime? smokedAt,
    String? note,
  }) async {
    _logs.add(
      _StubSmokingLog(
        logId: 'stub-log-id-${_logs.length + 1}',
        count: count,
        smokedAt: smokedAt ?? DateTime.now(),
        trigger: trigger,
        note: note,
      ),
    );
    return 'stub-log-id';
  }

  @override
  Future<int> getTotalSmokedToday() async {
    final now = DateTime.now();
    return _logs
        .where(
          (log) =>
              log.smokedAt.year == now.year &&
              log.smokedAt.month == now.month &&
              log.smokedAt.day == now.day,
        )
        .fold<int>(0, (sum, log) => sum + log.count);
  }

  @override
  Future<DateTime?> getLatestSmokedAt() async {
    if (_logs.isEmpty) {
      return null;
    }
    _logs.sort((a, b) => b.smokedAt.compareTo(a.smokedAt));
    return _logs.first.smokedAt;
  }

  @override
  Future<List<SmokingLogRecord>> getRecent({int limit = 90}) async {
    final rows = _logs.toList()
      ..sort((a, b) => b.smokedAt.compareTo(a.smokedAt));
    return rows
        .take(limit)
        .map(
          (log) => SmokingLogRecord(
            logId: log.logId,
            count: log.count,
            trigger: log.trigger,
            smokedAt: log.smokedAt,
            note: log.note,
          ),
        )
        .toList();
  }
}

class _StubSmokingLog {
  const _StubSmokingLog({
    required this.logId,
    required this.count,
    required this.smokedAt,
    required this.trigger,
    this.note,
  });

  final String logId;
  final int count;
  final DateTime smokedAt;
  final String trigger;
  final String? note;
}
