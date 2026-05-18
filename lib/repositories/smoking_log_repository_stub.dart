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
        count: count,
        smokedAt: smokedAt ?? DateTime.now(),
        trigger: trigger,
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
}

class _StubSmokingLog {
  const _StubSmokingLog({
    required this.count,
    required this.smokedAt,
    required this.trigger,
  });

  final int count;
  final DateTime smokedAt;
  final String trigger;
}
