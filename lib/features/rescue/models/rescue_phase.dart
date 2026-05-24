import 'dart:math' as math;

import 'package:flutter/material.dart';

enum RescuePhaseInteraction { optional, requiredAtHighIntensity }

class RescuePhase {
  const RescuePhase({
    required this.id,
    required this.title,
    required this.instruction,
    required this.duration,
    required this.icon,
    required this.completeLabel,
    required this.interaction,
  });

  final String id;
  final String title;
  final String instruction;
  final Duration duration;
  final IconData icon;
  final String completeLabel;
  final RescuePhaseInteraction interaction;

  bool requiresConfirmation(int intensity) {
    return intensity >= 8 &&
        interaction == RescuePhaseInteraction.requiredAtHighIntensity;
  }
}

const rescuePhases = [
  RescuePhase(
    id: 'water',
    title: 'Drink water',
    instruction: 'Take a full glass slowly. Let your hands do one simple job.',
    duration: Duration(seconds: 30),
    icon: Icons.water_drop_rounded,
    completeLabel: 'I drank water',
    interaction: RescuePhaseInteraction.requiredAtHighIntensity,
  ),
  RescuePhase(
    id: 'breathing',
    title: 'Breathe down',
    instruction:
        'Follow the circle. Inhale, hold, then let the exhale be long.',
    duration: Duration(seconds: 30),
    icon: Icons.self_improvement_rounded,
    completeLabel: 'I followed the breath',
    interaction: RescuePhaseInteraction.optional,
  ),
  RescuePhase(
    id: 'walk',
    title: 'Change location',
    instruction: 'Stand up or walk to another room. Change the cue around you.',
    duration: Duration(seconds: 30),
    icon: Icons.directions_walk_rounded,
    completeLabel: 'I moved',
    interaction: RescuePhaseInteraction.requiredAtHighIntensity,
  ),
  RescuePhase(
    id: 'reason',
    title: 'Read your reason',
    instruction: 'Read it once. You only need a gap, not a perfect mood.',
    duration: Duration(seconds: 30),
    icon: Icons.favorite_rounded,
    completeLabel: 'I read it',
    interaction: RescuePhaseInteraction.requiredAtHighIntensity,
  ),
];

class RescueProgressState {
  const RescueProgressState({
    this.phaseIndex = 0,
    this.remainingSeconds = 120,
    this.phaseRemainingSeconds = 30,
    this.completedPhaseIds = const {},
    this.waitingForConfirmation = false,
    this.finished = false,
  });

  final int phaseIndex;
  final int remainingSeconds;
  final int phaseRemainingSeconds;
  final Set<String> completedPhaseIds;
  final bool waitingForConfirmation;
  final bool finished;

  RescuePhase get currentPhase => rescuePhases[phaseIndex];

  double get totalProgress => 1 - (remainingSeconds / 120);

  double get phaseProgress {
    final total = currentPhase.duration.inSeconds;
    return 1 - (phaseRemainingSeconds / total);
  }

  RescueProgressState tick({required int intensity}) {
    if (finished || waitingForConfirmation) {
      return this;
    }

    final nextRemaining = math.max(0, remainingSeconds - 1);
    final nextPhaseRemaining = math.max(0, phaseRemainingSeconds - 1);
    final timedOut = nextPhaseRemaining == 0;

    if (!timedOut) {
      return copyWith(
        remainingSeconds: nextRemaining,
        phaseRemainingSeconds: nextPhaseRemaining,
      );
    }

    if (currentPhase.requiresConfirmation(intensity) &&
        !completedPhaseIds.contains(currentPhase.id)) {
      return copyWith(
        remainingSeconds: nextRemaining,
        phaseRemainingSeconds: 0,
        waitingForConfirmation: true,
      );
    }

    return advanceFromCompletedPhase(nextRemainingSeconds: nextRemaining);
  }

  RescueProgressState completeCurrent({required int intensity}) {
    final completed = {...completedPhaseIds, currentPhase.id};
    if (phaseRemainingSeconds > 0 && !waitingForConfirmation) {
      return copyWith(completedPhaseIds: completed);
    }

    return copyWith(
      completedPhaseIds: completed,
      waitingForConfirmation: false,
    ).advanceFromCompletedPhase(nextRemainingSeconds: remainingSeconds);
  }

  RescueProgressState advanceFromCompletedPhase({
    required int nextRemainingSeconds,
  }) {
    if (phaseIndex >= rescuePhases.length - 1) {
      return copyWith(
        remainingSeconds: nextRemainingSeconds,
        phaseRemainingSeconds: 0,
        waitingForConfirmation: false,
        finished: true,
      );
    }

    return copyWith(
      phaseIndex: phaseIndex + 1,
      remainingSeconds: nextRemainingSeconds,
      phaseRemainingSeconds: rescuePhases[phaseIndex + 1].duration.inSeconds,
      waitingForConfirmation: false,
    );
  }

  RescueProgressState copyWith({
    int? phaseIndex,
    int? remainingSeconds,
    int? phaseRemainingSeconds,
    Set<String>? completedPhaseIds,
    bool? waitingForConfirmation,
    bool? finished,
  }) {
    return RescueProgressState(
      phaseIndex: phaseIndex ?? this.phaseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      phaseRemainingSeconds:
          phaseRemainingSeconds ?? this.phaseRemainingSeconds,
      completedPhaseIds: completedPhaseIds ?? this.completedPhaseIds,
      waitingForConfirmation:
          waitingForConfirmation ?? this.waitingForConfirmation,
      finished: finished ?? this.finished,
    );
  }
}
