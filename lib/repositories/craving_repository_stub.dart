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
    int intensity = 6,
    List<String> triggers = const [],
  }) async {
    final sessionId = _uuid.v7();
    _sessions.insert(
      0,
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
    int? intensity,
    int? intensityAfter,
    List<String>? triggers,
    List<String>? toolsUsed,
    int? breaths,
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
      intensity: intensity ?? existing.intensity,
      triggers: triggers ?? existing.triggers,
      outcome: outcome,
      intensityAfter: intensityAfter ?? existing.intensityAfter,
      toolsUsed: toolsUsed ?? existing.toolsUsed,
      breaths: breaths ?? existing.breaths,
    );
  }

  Future<List<CravingRescueData>> recent({int limit = 20}) async {
    return _sessions.take(limit).toList();
  }

  Future<int> resistedCount() async {
    return _sessions.where((session) => session.resisted).length;
  }
}
