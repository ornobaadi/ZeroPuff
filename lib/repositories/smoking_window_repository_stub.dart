import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/smoking_window_data.dart';
import 'smoking_window_repository.dart';

SmokingWindowRepository getSmokingWindowRepository(Ref ref) {
  return SmokingWindowRepositoryStub();
}

class SmokingWindowRepositoryStub implements SmokingWindowRepository {
  SmokingWindowData _primary = SmokingWindowData.defaultWindow();

  @override
  Future<SmokingWindowData> loadPrimary() async => _primary;

  @override
  Future<void> savePrimary({
    required String userId,
    required SmokingWindowData window,
  }) async {
    _primary = window;
  }
}
