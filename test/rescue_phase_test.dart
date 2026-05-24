import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/features/rescue/models/rescue_phase.dart';

void main() {
  group('RescueProgressState', () {
    test('starts on the water phase with two minutes remaining', () {
      const state = RescueProgressState();

      expect(state.currentPhase.id, 'water');
      expect(state.remainingSeconds, 120);
      expect(state.phaseRemainingSeconds, 30);
      expect(state.finished, isFalse);
    });

    test('auto advances phases for low and medium intensity', () {
      var state = const RescueProgressState();

      for (var i = 0; i < 30; i++) {
        state = state.tick(intensity: 5);
      }

      expect(state.currentPhase.id, 'breathing');
      expect(state.remainingSeconds, 90);
      expect(state.waitingForConfirmation, isFalse);
    });

    test('high intensity waits for confirmation on concrete action phases', () {
      var state = const RescueProgressState();

      for (var i = 0; i < 30; i++) {
        state = state.tick(intensity: 10);
      }

      expect(state.currentPhase.id, 'water');
      expect(state.phaseRemainingSeconds, 0);
      expect(state.waitingForConfirmation, isTrue);

      state = state.completeCurrent(intensity: 10);

      expect(state.currentPhase.id, 'breathing');
      expect(state.completedPhaseIds, contains('water'));
      expect(state.waitingForConfirmation, isFalse);
    });

    test('optional completion notes a phase without skipping its timer', () {
      var state = const RescueProgressState(phaseIndex: 1);

      state = state.completeCurrent(intensity: 10);

      expect(state.currentPhase.id, 'breathing');
      expect(state.completedPhaseIds, contains('breathing'));
      expect(state.phaseRemainingSeconds, 30);
    });

    test('finishes after all four timed phases', () {
      var state = const RescueProgressState();

      for (var i = 0; i < 120; i++) {
        state = state.tick(intensity: 5);
      }

      expect(state.finished, isTrue);
      expect(state.remainingSeconds, 0);
      expect(state.currentPhase.id, 'reason');
    });
  });
}
