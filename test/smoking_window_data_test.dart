import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/models/smoking_window_data.dart';

void main() {
  group('SmokingWindowData', () {
    test('formats display labels', () {
      expect(SmokingWindowData.labelForMinutes(18 * 60), '6:00 PM');
      expect(SmokingWindowData.labelForMinutes(23 * 60 + 30), '11:30 PM');
      expect(SmokingWindowData.labelForMinutes(0), '12:00 AM');
    });

    test('formats and parses sql time values', () {
      const window = SmokingWindowData(
        startMinutes: 18 * 60,
        endMinutes: 23 * 60,
      );

      expect(window.startTimeSql, '18:00:00');
      expect(window.endTimeSql, '23:00:00');
      expect(SmokingWindowData.minutesFromSql('18:30:00'), 18 * 60 + 30);
    });
  });
}
