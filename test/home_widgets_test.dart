import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/core/widgets/rolling_number.dart';
import 'package:zeropuff/features/home/widgets/home_action_cards.dart';
import 'package:zeropuff/features/home/widgets/smoke_free_timer.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Finder _number(int value, {int minDigits = 1}) => find.byWidgetPredicate(
  (w) => w is RollingNumber && w.value == value && w.minDigits == minDigits,
);

void main() {
  group('ClockParts', () {
    test('leads with minutes in the first hour', () {
      final parts = ClockParts.of(const Duration(minutes: 12, seconds: 5));

      expect((parts.value, parts.unit), (12, 'minutes'));
      expect(parts.rest, [(5, 'sec')]);
    });

    test('leads with hours in the first day', () {
      final parts = ClockParts.of(const Duration(hours: 1, minutes: 30));

      expect((parts.value, parts.unit), (1, 'hour'));
      expect(parts.rest, [(30, 'min'), (0, 'sec')]);
    });

    test('leads with days after that', () {
      final parts = ClockParts.of(
        const Duration(days: 40, hours: 3, minutes: 4, seconds: 5),
      );

      expect((parts.value, parts.unit), (40, 'days'));
      expect(parts.rest, [(3, 'h'), (4, 'min'), (5, 'sec')]);
    });
  });

  group('SmokeFreeTimer', () {
    testWidgets('shows days with the smaller units in a line', (tester) async {
      final since = DateTime.now().subtract(
        const Duration(days: 2, hours: 3, minutes: 4),
      );
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(_number(2), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(_number(3, minDigits: 2), findsOneWidget);
      expect(_number(4, minDigits: 2), findsOneWidget);
      expect(find.text('h'), findsOneWidget);
    });

    testWidgets('uses the singular for one day', (tester) async {
      final since = DateTime.now().subtract(const Duration(days: 1, hours: 1));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(find.text('day'), findsOneWidget);
    });

    testWidgets('never opens on zero days', (tester) async {
      final since = DateTime.now().subtract(const Duration(hours: 5));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(_number(5), findsOneWidget);
      expect(find.text('hours'), findsOneWidget);
      expect(find.text('days'), findsNothing);
    });

    testWidgets('never shows negative time for a future start', (tester) async {
      final since = DateTime.now().add(const Duration(hours: 5));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(_number(0), findsOneWidget);
      expect(find.text('minutes'), findsOneWidget);
      expect(_number(0, minDigits: 2), findsOneWidget);
    });

    testWidgets('ticks every second', (tester) async {
      final since = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });

    testWidgets('speaks a label that ignores the ticking seconds', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final since = DateTime.now().subtract(
        const Duration(days: 3, hours: 2, minutes: 10, seconds: 30),
      );
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(
        find.bySemanticsLabel('Smoke-free for 3 days, 2 hours and 10 minutes'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('Home cards', () {
    testWidgets('craving button is labelled and tappable', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _host(CravingButton(onPressed: () => pressed = true)),
      );

      await tester.tap(find.text("I'm craving"));

      expect(pressed, isTrue);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('streak chip announces the streak', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(StreakChip(streak: 1, onTap: () {})));

      expect(find.bySemanticsLabel('Smoke-free streak: 1 day'), findsOneWidget);
      handle.dispose();
    });
  });
}
