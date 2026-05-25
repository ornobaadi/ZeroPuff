class SmokingWindowData {
  const SmokingWindowData({
    required this.startMinutes,
    required this.endMinutes,
    this.windowId = primaryWindowId,
    this.label = 'usual',
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.enabled = true,
    this.isPrimary = true,
    this.source = 'onboarding',
  });

  static const primaryWindowId = 'primary';

  final String windowId;
  final String label;
  final int startMinutes;
  final int endMinutes;
  final List<int> daysOfWeek;
  final bool enabled;
  final bool isPrimary;
  final String source;

  String get startTimeSql => _timeSql(startMinutes);
  String get endTimeSql => _timeSql(endMinutes);

  SmokingWindowData copyWith({
    String? windowId,
    String? label,
    int? startMinutes,
    int? endMinutes,
    List<int>? daysOfWeek,
    bool? enabled,
    bool? isPrimary,
    String? source,
  }) {
    return SmokingWindowData(
      windowId: windowId ?? this.windowId,
      label: label ?? this.label,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
      isPrimary: isPrimary ?? this.isPrimary,
      source: source ?? this.source,
    );
  }

  static SmokingWindowData defaultWindow() {
    return const SmokingWindowData(startMinutes: 18 * 60, endMinutes: 23 * 60);
  }

  static int? minutesFromSql(Object? value) {
    if (value == null) {
      return null;
    }
    final parts = value.toString().split(':');
    if (parts.length < 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return (hour * 60 + minute).clamp(0, 24 * 60);
  }

  static String labelForMinutes(int minutes) {
    final normalized = minutes.clamp(0, 24 * 60);
    final hour24 = normalized == 24 * 60 ? 0 : normalized ~/ 60;
    final minute = normalized.remainder(60);
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minuteLabel = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteLabel $suffix';
  }

  static String _timeSql(int minutes) {
    final normalized = minutes.clamp(0, 24 * 60);
    final hour = normalized == 24 * 60 ? 0 : normalized ~/ 60;
    final minute = normalized.remainder(60);
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';
  }
}
