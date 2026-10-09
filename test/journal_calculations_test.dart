import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/day_history.dart';
import 'package:zeropuff/core/calculations/journal_calculations.dart';

void main() {
  group('JournalCalculations', () {
    test('a day since the quit date is smoke-free with nothing logged', () {
      final status = JournalCalculations.statusForDay(
        kind: DayKind.smokeFree,
        cravingCount: 0,
      );

      expect(status, JournalDayStatus.smokeFree);
    });

    test('a smoke-free day with cravings is marked for them', () {
      final status = JournalCalculations.statusForDay(
        kind: DayKind.smokeFree,
        cravingCount: 2,
      );

      expect(status, JournalDayStatus.craving);
    });

    test('a day with a cigarette is a relapse, or mixed with cravings', () {
      expect(
        JournalCalculations.statusForDay(
          kind: DayKind.slipped,
          cravingCount: 0,
        ),
        JournalDayStatus.relapse,
      );
      expect(
        JournalCalculations.statusForDay(
          kind: DayKind.slipped,
          cravingCount: 1,
        ),
        JournalDayStatus.mixed,
      );
    });

    test('days ahead and days before quitting say nothing', () {
      expect(
        JournalCalculations.statusForDay(kind: DayKind.future, cravingCount: 0),
        JournalDayStatus.future,
      );
      expect(
        JournalCalculations.statusForDay(
          kind: DayKind.beforeQuit,
          cravingCount: 3,
        ),
        JournalDayStatus.noData,
      );
    });

    test('builds a complete month grid with leading blanks', () {
      final cells = JournalCalculations.monthGrid(DateTime(2026, 5));

      expect(cells.length % DateTime.daysPerWeek, 0);
      expect(cells.take(5), everyElement(isNull));
      expect(cells.whereType<DateTime>().length, 31);
    });
  });
}
