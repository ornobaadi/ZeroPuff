import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/features/rescue/models/rescue_flow.dart';

void main() {
  RescueFlow afterBreaths(int count) {
    var flow = const RescueFlow();
    for (var index = 0; index < count; index++) {
      flow = flow.addBreath();
    }
    return flow;
  }

  group('RescueFlow', () {
    test('starts on breathing with nothing recorded', () {
      const flow = RescueFlow();

      expect(flow.stage, RescueStage.breathe);
      expect(flow.hasStarted, isFalse);
      expect(flow.intensityAfter, isNull);
    });

    test('moves to the check after a full round of breaths', () {
      expect(afterBreaths(RescueFlow.breathTarget - 1).stage,
          RescueStage.breathe);

      final flow = afterBreaths(RescueFlow.breathTarget);
      expect(flow.stage, RescueStage.check);
      expect(flow.breaths, RescueFlow.breathTarget);
    });

    test('skipping ahead goes to the check and counts as started', () {
      final flow = const RescueFlow().skipToCheck();

      expect(flow.stage, RescueStage.check);
      expect(flow.hasStarted, isTrue);
    });

    test('an urge that passed or weakened ends on the win', () {
      final gone = afterBreaths(6)
          .withStartStrength(UrgeStrength.intense)
          .answerNow(UrgeNow.gone);
      expect(gone.stage, RescueStage.win);
      expect(gone.intensityBefore, 9);
      expect(gone.intensityAfter, 1);

      final weaker = afterBreaths(6).answerNow(UrgeNow.weaker);
      expect(weaker.stage, RescueStage.win);
      expect(weaker.intensityAfter, lessThan(weaker.intensityBefore));
    });

    test('a strong urge offers other tools instead of repeating', () {
      final flow = afterBreaths(6).answerNow(UrgeNow.stillStrong);

      expect(flow.stage, RescueStage.tools);
      expect(flow.intensityAfter, flow.intensityBefore);
      expect(flow.outcomeIfLeft, 'still_craving');
    });

    test('a tool is remembered once and returns to the check', () {
      final tools = afterBreaths(6).answerNow(UrgeNow.stillStrong);
      final inTool = tools.pickTool('grounding');
      expect(inTool.stage, RescueStage.tool);
      expect(inTool.activeToolId, 'grounding');

      final again = inTool
          .finishTool()
          .answerNow(UrgeNow.stillStrong)
          .pickTool('grounding');
      expect(again.toolsUsed, ['grounding']);
      expect(again.finishTool().stage, RescueStage.check);
      expect(again.backToTools().stage, RescueStage.tools);
    });

    test('breathing again starts a fresh round and keeps the total', () {
      final flow = afterBreaths(6).answerNow(UrgeNow.stillStrong).breatheAgain();

      expect(flow.stage, RescueStage.breathe);
      expect(flow.breathsThisRound, 0);
      expect(flow.addBreath().breaths, 7);
    });

    test('leaving before answering is recorded as abandoned', () {
      expect(afterBreaths(2).outcomeIfLeft, 'abandoned');
    });

    test('answers are ignored outside the check', () {
      const flow = RescueFlow();
      expect(identical(flow.answerNow(UrgeNow.gone), flow), isTrue);
      expect(identical(flow.pickTool('water'), flow), isTrue);
    });
  });
}
