/// Where the user is in a rescue.
enum RescueStage { breathe, check, tools, tool, win }

/// How strong the urge was when it started, on the stored 1-10 scale.
enum UrgeStrength {
  mild('Mild', 3),
  strong('Strong', 6),
  intense('Intense', 9);

  const UrgeStrength(this.label, this.intensity);

  final String label;
  final int intensity;
}

/// The user's answer to "how is it now?".
enum UrgeNow { gone, weaker, stillStrong }

/// The state of one rescue: breathe first, check the urge, and if it is still
/// strong try a different tool rather than repeating the same thing.
class RescueFlow {
  const RescueFlow({
    this.stage = RescueStage.breathe,
    this.breaths = 0,
    this.startStrength = UrgeStrength.strong,
    this.answer,
    this.activeToolId,
    this.toolsUsed = const [],
  });

  /// Breaths in one round. Around a minute at an unhurried pace.
  static const breathTarget = 6;

  final RescueStage stage;
  final int breaths;
  final UrgeStrength startStrength;
  final UrgeNow? answer;
  final String? activeToolId;
  final List<String> toolsUsed;

  /// Breaths taken in the current round of [breathTarget].
  int get breathsThisRound =>
      stage == RescueStage.breathe ? breaths % breathTarget : breathTarget;

  bool get hasStarted => breaths > 0 || stage != RescueStage.breathe;

  int get intensityBefore => startStrength.intensity;

  /// The urge after the rescue on the 1-10 scale, once the user has answered.
  int? get intensityAfter => switch (answer) {
    null => null,
    UrgeNow.gone => 1,
    UrgeNow.weaker => (intensityBefore / 2).ceil(),
    UrgeNow.stillStrong => intensityBefore,
  };

  /// What to record if the user leaves before finishing.
  String get outcomeIfLeft =>
      answer == UrgeNow.stillStrong ? 'still_craving' : 'abandoned';

  RescueFlow addBreath() {
    if (stage != RescueStage.breathe) {
      return this;
    }
    final next = breaths + 1;
    return _copy(
      breaths: next,
      stage: next % breathTarget == 0 ? RescueStage.check : stage,
    );
  }

  /// Moves on to the check before the round is finished.
  RescueFlow skipToCheck() {
    return stage == RescueStage.breathe
        ? _copy(stage: RescueStage.check)
        : this;
  }

  RescueFlow withStartStrength(UrgeStrength strength) {
    return _copy(startStrength: strength);
  }

  RescueFlow answerNow(UrgeNow now) {
    if (stage != RescueStage.check) {
      return this;
    }
    return _copy(
      answer: now,
      stage: now == UrgeNow.stillStrong ? RescueStage.tools : RescueStage.win,
    );
  }

  RescueFlow pickTool(String toolId) {
    if (stage != RescueStage.tools) {
      return this;
    }
    return _copy(
      stage: RescueStage.tool,
      activeToolId: toolId,
      toolsUsed: toolsUsed.contains(toolId)
          ? toolsUsed
          : [...toolsUsed, toolId],
    );
  }

  /// Back to the check after a tool, or to another round of breathing.
  RescueFlow finishTool() {
    return stage == RescueStage.tool ? _copy(stage: RescueStage.check) : this;
  }

  RescueFlow breatheAgain() {
    return stage == RescueStage.tools
        ? _copy(stage: RescueStage.breathe)
        : this;
  }

  RescueFlow backToTools() {
    return stage == RescueStage.tool ? _copy(stage: RescueStage.tools) : this;
  }

  RescueFlow _copy({
    RescueStage? stage,
    int? breaths,
    UrgeStrength? startStrength,
    UrgeNow? answer,
    String? activeToolId,
    List<String>? toolsUsed,
  }) {
    return RescueFlow(
      stage: stage ?? this.stage,
      breaths: breaths ?? this.breaths,
      startStrength: startStrength ?? this.startStrength,
      answer: answer ?? this.answer,
      activeToolId: activeToolId ?? this.activeToolId,
      toolsUsed: toolsUsed ?? this.toolsUsed,
    );
  }
}
