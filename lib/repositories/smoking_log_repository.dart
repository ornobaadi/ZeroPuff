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
}
