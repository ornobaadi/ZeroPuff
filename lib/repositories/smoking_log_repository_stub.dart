import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'smoking_log_repository.dart';

SmokingLogRepository getSmokingLogRepository(Ref ref) {
  return SmokingLogRepositoryStub();
}

class SmokingLogRepositoryStub implements SmokingLogRepository {
  @override
  Future<String> addLog({
    required int count,
    required String trigger,
    String? note,
  }) async {
    return 'stub-log-id';
  }

  @override
  Future<int> getTotalSmokedToday() async {
    return 0;
  }
}
