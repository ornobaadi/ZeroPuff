import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/smoking_window_data.dart';
import 'smoking_window_repository.dart';

SmokingWindowRepository getSmokingWindowRepository(Ref ref) {
  return SmokingWindowRepositoryStub();
}

class SmokingWindowRepositoryStub implements SmokingWindowRepository {
  SmokingWindowData _primary = SmokingWindowData.defaultWindow();
  final Map<String, SmokingWindowData> _rituals = {};

  @override
  Future<SmokingWindowData> loadPrimary() async => _primary;

  @override
  Future<void> savePrimary({
    required String userId,
    required SmokingWindowData window,
  }) async {
    _primary = window;
  }

  @override
  Future<List<SmokingWindowData>> loadRituals() async {
    return _rituals.values.toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  @override
  Future<void> saveRitual({
    required String userId,
    required SmokingWindowData ritual,
  }) async {
    _rituals[ritual.windowId] = ritual;
  }

  @override
  Future<void> deleteRitual(String windowId) async {
    _rituals.remove(windowId);
  }
}
