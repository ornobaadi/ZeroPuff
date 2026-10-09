class CravingRescueData {
  const CravingRescueData({
    required this.sessionId,
    required this.startedAt,
    required this.intensity,
    required this.triggers,
    this.completedAt,
    this.outcome = 'unknown',
    this.intensityAfter,
    this.toolsUsed = const [],
    this.breaths = 0,
  });

  final String sessionId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int intensity;
  final List<String> triggers;

  /// One of `unknown`, `resisted`, `smoked`, `still_craving`, `abandoned`.
  final String outcome;
  final int? intensityAfter;
  final List<String> toolsUsed;
  final int breaths;

  bool get resisted => outcome == 'resisted';
}
