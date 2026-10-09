import '../../models/smoking_window_data.dart';

/// Slips that keep happening around the same time of day.
class SlipPattern {
  const SlipPattern({required this.startMinutes, required this.count});

  /// How far apart, in minutes of the day, slips still count as the same time.
  static const windowMinutes = 90;

  /// When the pattern starts, in minutes after midnight, on the half hour.
  final int startMinutes;

  /// Slips in the pattern, including the latest.
  final int count;

  /// A name for the moment, to use if it is added as a smoking moment.
  String get momentLabel {
    return 'Your ${SmokingWindowData.labelForMinutes(startMinutes).replaceFirst(':00', '')} moment';
  }

  /// Looks for a pattern around the [latest] slip: at least two slips at
  /// about the same time of day that no existing smoking moment already
  /// covers. Returns null when there is nothing new to suggest.
  static SlipPattern? detect({
    required List<DateTime> slipTimes,
    required DateTime latest,
    required List<SmokingWindowData> moments,
  }) {
    final latestMinutes = _minutes(latest);
    final offsets = slipTimes
        .map((time) => _offset(_minutes(time), latestMinutes))
        .where((offset) => offset.abs() <= windowMinutes)
        .toList();
    if (offsets.length < 2) {
      return null;
    }

    final covered = moments.any(
      (moment) =>
          moment.enabled &&
          _offset(moment.startMinutes, latestMinutes).abs() <= windowMinutes,
    );
    if (covered) {
      return null;
    }

    final mean = offsets.reduce((a, b) => a + b) / offsets.length;
    final centre = (latestMinutes + mean.round()) % (24 * 60);
    return SlipPattern(
      startMinutes: centre - centre % 30,
      count: offsets.length,
    );
  }

  static int _minutes(DateTime time) => time.hour * 60 + time.minute;

  /// The signed distance from [from] to [minutes] around the clock, so 23:50
  /// and 00:10 are twenty minutes apart.
  static int _offset(int minutes, int from) {
    var offset = (minutes - from) % (24 * 60);
    if (offset > 12 * 60) {
      offset -= 24 * 60;
    }
    return offset;
  }
}
