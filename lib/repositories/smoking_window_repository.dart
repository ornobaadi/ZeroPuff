import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'smoking_window_repository_stub.dart'
    if (dart.library.io) 'smoking_window_repository_io.dart';
import '../models/smoking_window_data.dart';

final smokingWindowRepositoryProvider = Provider<SmokingWindowRepository>((
  ref,
) {
  return getSmokingWindowRepository(ref);
});

abstract class SmokingWindowRepository {
  Future<SmokingWindowData> loadPrimary();

  Future<void> savePrimary({
    required String userId,
    required SmokingWindowData window,
  });
}
