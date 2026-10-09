import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/calculations/day_history.dart';
import 'package:zeropuff/core/calculations/slip_pattern.dart';
import 'package:zeropuff/models/smoking_window_data.dart';

void main() {
  final quit = DateTime(2026, 10, 1, 9);
  final today = DateTime(2026, 10, 10, 15);

  DayHistory history({
    List<DateTime> slips = const [],
    List<DateTime> sealed = const [],
    DateTime? now,
  }) {
    return DayHistory(
      quitDate: quit,
      today: now ?? today,
      slipDays: slips,
      sealedDays: sealed,
    );
  }

  group('Smoke-free run', () {
    test('counts every clear day up to yesterday without any sealing', () {
      // 1st to 9th: nine days. Nothing was ever confirmed.
      expect(history().currentRun, 9);
    });

    test('a skipped evening never breaks the run', () {
      final run = history(
        sealed: [DateTime(2026, 10, 2), DateTime(2026, 10, 7)],
      ).currentRun;

      expect(run, 9);
    });

    test('sealing today counts today early', () {
      expect(history(sealed: [DateTime(2026, 10, 10)]).currentRun, 10);
    });

    test('a cigarette today brings the run to zero', () {
      final slipped = history(
        slips: [DateTime(2026, 10, 10, 11)],
        sealed: [DateTime(2026, 10, 10)],
      );

      expect(slipped.currentRun, 0);
      expect(slipped.runStart, isNull);
    });

    test('a past cigarette restarts the run from the day after', () {
      final after = history(slips: [DateTime(2026, 10, 6, 21)]);

      // 7th, 8th and 9th.
      expect(after.currentRun, 3);
      expect(after.runStart, DateTime(2026, 10, 7));
    });

    test('is zero on the quit day until it is sealed', () {
      final now = DateTime(2026, 10, 1, 20);

      expect(history(now: now).currentRun, 0);
      expect(history(now: now, sealed: [now]).currentRun, 1);
    });

    test('is zero while the quit date is still ahead', () {
      final before = history(now: DateTime(2026, 9, 28));

      expect(before.started, isFalse);
      expect(before.currentRun, 0);
      expect(before.bestRun, 0);
    });
  });

  group('History', () {
    test('keeps the best run after a slip', () {
      final after = history(slips: [DateTime(2026, 10, 6, 21)]);

      // 1st to 5th was five days; the current run is three.
      expect(after.bestRun, 5);
      expect(after.smokeFreeDays, 8);
    });

    test('records where runs ended, not every cigarette', () {
      final ends = history(
        slips: [
          DateTime(2026, 10, 4),
          DateTime(2026, 10, 5),
          DateTime(2026, 10, 8),
        ],
      ).runEnds;

      // The 5th followed another slip, so no run ended there.
      expect(ends, [DateTime(2026, 10, 4), DateTime(2026, 10, 8)]);
    });

    test('describes each day', () {
      final days = history(
        slips: [DateTime(2026, 10, 8)],
        sealed: [DateTime(2026, 10, 9)],
      );

      expect(days.stateFor(DateTime(2026, 9, 30)).kind, DayKind.beforeQuit);
      expect(days.stateFor(DateTime(2026, 10, 8)).kind, DayKind.slipped);
      expect(days.stateFor(DateTime(2026, 10, 9)).sealed, isTrue);
      expect(days.stateFor(DateTime(2026, 10, 9)).smokeFree, isTrue);
      expect(days.stateFor(DateTime(2026, 10, 10)).isToday, isTrue);
      expect(days.stateFor(DateTime(2026, 10, 11)).kind, DayKind.future);
      expect(days.sealedCount, 1);
    });

    test('lists the last days oldest first, ending today', () {
      final week = history().lastDays(7);

      expect(week.length, 7);
      expect(week.first.date, DateTime(2026, 10, 4));
      expect(week.last.isToday, isTrue);
    });
  });

  group('Slip pattern', () {
    SmokingWindowData moment(int hour) {
      return SmokingWindowData.ritual(
        windowId: '$hour',
        label: 'Moment',
        startMinutes: hour * 60,
      );
    }

    test('finds slips that repeat around the same time of day', () {
      final pattern = SlipPattern.detect(
        slipTimes: [
          DateTime(2026, 10, 3, 21, 20),
          DateTime(2026, 10, 6, 20, 50),
          DateTime(2026, 10, 9, 21, 5),
          DateTime(2026, 10, 7, 8, 0),
        ],
        latest: DateTime(2026, 10, 9, 21, 5),
        moments: const [],
      );

      expect(pattern, isNotNull);
      expect(pattern!.count, 3);
      expect(pattern.startMinutes, 21 * 60);
      expect(pattern.momentLabel, 'Your 9 PM moment');
    });

    test('says nothing about a single slip', () {
      final pattern = SlipPattern.detect(
        slipTimes: [DateTime(2026, 10, 9, 21, 5)],
        latest: DateTime(2026, 10, 9, 21, 5),
        moments: const [],
      );

      expect(pattern, isNull);
    });

    test('says nothing when a smoking moment already covers the time', () {
      final pattern = SlipPattern.detect(
        slipTimes: [
          DateTime(2026, 10, 6, 20, 50),
          DateTime(2026, 10, 9, 21, 5),
        ],
        latest: DateTime(2026, 10, 9, 21, 5),
        moments: [moment(20)],
      );

      expect(pattern, isNull);
    });

    test('treats times either side of midnight as close', () {
      final pattern = SlipPattern.detect(
        slipTimes: [
          DateTime(2026, 10, 6, 23, 50),
          DateTime(2026, 10, 9, 0, 20),
        ],
        latest: DateTime(2026, 10, 9, 0, 20),
        moments: const [],
      );

      expect(pattern, isNotNull);
      expect(pattern!.count, 2);
    });
  });
}
