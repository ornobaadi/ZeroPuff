import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/craving_analysis_calculations.dart';
import 'package:zeropuff/models/craving_rescue_data.dart';
import 'package:zeropuff/repositories/smoking_log_repository.dart';

void main() {
  group('CravingAnalysisCalculations', () {
    test('returns empty-state insights before three craving logs', () {
      final now = DateTime(2026, 5, 19, 12);
      final analysis = CravingAnalysisCalculations.analyze(
        cravings: [
          _craving(now.subtract(const Duration(hours: 2)), ['stress']),
          _craving(now.subtract(const Duration(hours: 1)), ['coffee']),
        ],
        smokingLogs: const [],
        now: now,
      );

      expect(analysis.hasEnoughData, isFalse);
      expect(analysis.insights.first, contains('three cravings'));
    });

    test('calculates top triggers, peak window, and resistance rate', () {
      final now = DateTime(2026, 5, 19, 23);
      final analysis = CravingAnalysisCalculations.analyze(
        cravings: [
          _craving(
            DateTime(2026, 5, 19, 21),
            ['stress'],
            intensity: 8,
            outcome: 'resisted',
          ),
          _craving(
            DateTime(2026, 5, 18, 22),
            ['stress', 'routine'],
            intensity: 6,
            outcome: 'smoked',
          ),
          _craving(
            DateTime(2026, 5, 17, 10),
            ['coffee'],
            intensity: 4,
            outcome: 'resisted',
          ),
        ],
        smokingLogs: const [],
        now: now,
      );

      expect(analysis.hasEnoughData, isTrue);
      expect(analysis.topTriggers.first.trigger, 'stress');
      expect(analysis.topTriggers.first.count, 2);
      expect(analysis.peakWindow?.label, '9 PM-11 PM');
      expect((analysis.resistanceRate * 100).round(), 67);
      expect(analysis.averageIntensity, 6);
    });

    test('compares rolling week counts and smoke-free days this month', () {
      final now = DateTime(2026, 5, 19, 12);
      final analysis = CravingAnalysisCalculations.analyze(
        cravings: [
          _craving(DateTime(2026, 5, 19, 9), ['stress']),
          _craving(DateTime(2026, 5, 13, 9), ['stress']),
          _craving(DateTime(2026, 5, 9, 9), ['stress']),
        ],
        smokingLogs: [
          SmokingLogRecord(
            logId: 'a',
            count: 1,
            trigger: 'stress',
            smokedAt: DateTime(2026, 5, 2),
          ),
          SmokingLogRecord(
            logId: 'b',
            count: 1,
            trigger: 'stress',
            smokedAt: DateTime(2026, 5, 18),
          ),
          SmokingLogRecord(
            logId: 'c',
            count: 1,
            trigger: 'stress',
            smokedAt: DateTime(2026, 4, 30),
          ),
        ],
        now: now,
      );

      expect(analysis.cravingsThisWeek, 2);
      expect(analysis.cravingsLastWeek, 1);
      expect(analysis.smokeFreeDaysThisMonth, 17);
    });
  });
}

CravingRescueData _craving(
  DateTime startedAt,
  List<String> triggers, {
  int intensity = 5,
  String outcome = 'resisted',
}) {
  return CravingRescueData(
    sessionId: startedAt.toIso8601String(),
    startedAt: startedAt,
    intensity: intensity,
    triggers: triggers,
    outcome: outcome,
  );
}
