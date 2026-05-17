class AppEvent {
  const AppEvent({
    required this.eventName,
    this.properties = const {},
    this.createdAt,
  });

  final String eventName;
  final Map<String, Object?> properties;
  final DateTime? createdAt;
}
