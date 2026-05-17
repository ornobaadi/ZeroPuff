class CravingRescueData {
  const CravingRescueData({
    required this.sessionId,
    required this.startedAt,
    required this.intensity,
    required this.triggers,
    this.completedAt,
    this.outcome = 'unknown',
  });

  final String sessionId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int intensity;
  final List<String> triggers;
  final String outcome;
}
