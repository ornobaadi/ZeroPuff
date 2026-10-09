import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'smoking_window_repository_stub.dart'
    if (dart.library.io) 'smoking_window_repository_io.dart';
import '../models/smoking_window_data.dart';

final smokingWindowRepositoryProvider = Provider<SmokingWindowRepository>((
  ref,
) {
  return getSmokingWindowRepository(ref);
});

/// The user's rituals, earliest in the day first.
final ritualsProvider = FutureProvider<List<SmokingWindowData>>((ref) {
  return ref.watch(smokingWindowRepositoryProvider).loadRituals();
});

abstract class SmokingWindowRepository {
  Future<SmokingWindowData> loadPrimary();

  Future<void> savePrimary({
    required String userId,
    required SmokingWindowData window,
  });

  /// Named moments of the day that used to come with a cigarette, earliest
  /// first. Separate from the single "usual" window.
  Future<List<SmokingWindowData>> loadRituals();

  /// Adds a ritual, or updates the one with the same id.
  Future<void> saveRitual({
    required String userId,
    required SmokingWindowData ritual,
  });

  Future<void> deleteRitual(String windowId);
}
