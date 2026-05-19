import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/journal_calculations.dart';

void main() {
  group('JournalCalculations', () {
    test('marks future days separately', () {
      final status = JournalCalculations.statusForDay(
        day: DateTime(2026, 5, 20),
        today: DateTime(2026, 5, 19),
        hasCheckIn: false,
        smokeFreeCheckIn: false,
        checkInCigarettes: 0,
        smokingLogCount: 0,
        cravingCount: 0,
      );

      expect(status, JournalDayStatus.future);
    });

    test('marks smoke-free check-in days', () {
      final status = JournalCalculations.statusForDay(
        day: DateTime(2026, 5, 19),
        today: DateTime(2026, 5, 19),
        hasCheckIn: true,
        smokeFreeCheckIn: true,
        checkInCigarettes: 0,
        smokingLogCount: 0,
        cravingCount: 0,
      );

      expect(status, JournalDayStatus.smokeFree);
    });

    test('marks relapse days from smoke logs', () {
      final status = JournalCalculations.statusForDay(
        day: DateTime(2026, 5, 19),
        today: DateTime(2026, 5, 19),
        hasCheckIn: true,
        smokeFreeCheckIn: false,
        checkInCigarettes: 0,
        smokingLogCount: 1,
        cravingCount: 0,
      );

      expect(status, JournalDayStatus.relapse);
    });

    test('marks mixed days when cravings and smoking both happened', () {
      final status = JournalCalculations.statusForDay(
        day: DateTime(2026, 5, 19),
        today: DateTime(2026, 5, 19),
        hasCheckIn: false,
        smokeFreeCheckIn: false,
        checkInCigarettes: 0,
        smokingLogCount: 1,
        cravingCount: 2,
      );

      expect(status, JournalDayStatus.mixed);
    });

    test('builds a complete month grid with leading blanks', () {
      final cells = JournalCalculations.monthGrid(DateTime(2026, 5));

      expect(cells.length % DateTime.daysPerWeek, 0);
      expect(cells.take(5), everyElement(isNull));
      expect(cells.whereType<DateTime>().length, 31);
    });
  });
}
