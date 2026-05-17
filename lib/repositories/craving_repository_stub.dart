import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/craving_rescue_data.dart';

final cravingRepositoryProvider = Provider<CravingRepository>((ref) {
  return CravingRepository();
});

class CravingRepository {
  final Uuid _uuid = const Uuid();
  final List<CravingRescueData> _sessions = [];

  Future<String> startRescue({
    required int intensity,
    required List<String> triggers,
  }) async {
    final sessionId = _uuid.v7();
    _sessions.add(
      CravingRescueData(
        sessionId: sessionId,
        startedAt: DateTime.now(),
        intensity: intensity,
        triggers: triggers,
      ),
    );
    return sessionId;
  }

  Future<void> completeRescue({
    required String sessionId,
    required String outcome,
  }) async {
    final index = _sessions.indexWhere((item) => item.sessionId == sessionId);
    if (index == -1) {
      return;
    }
    final existing = _sessions[index];
    _sessions[index] = CravingRescueData(
      sessionId: existing.sessionId,
      startedAt: existing.startedAt,
      completedAt: DateTime.now(),
      intensity: existing.intensity,
      triggers: existing.triggers,
      outcome: outcome,
    );
  }

  Future<List<CravingRescueData>> recent({int limit = 20}) async {
    return _sessions.take(limit).toList();
  }
}
