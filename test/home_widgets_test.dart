import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/home/widgets/home_action_cards.dart';
import 'package:zeropuff/features/home/widgets/smoke_free_timer.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('SmokeFreeTimer', () {
    testWidgets('shows days, hours, minutes and seconds', (tester) async {
      final since = DateTime.now().subtract(
        const Duration(days: 2, hours: 3, minutes: 4),
      );
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(find.text('2'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
      expect(find.text('04'), findsOneWidget);
    });

    testWidgets('uses the singular for one day', (tester) async {
      final since = DateTime.now().subtract(const Duration(days: 1, hours: 1));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(find.text('day'), findsOneWidget);
    });

    testWidgets('never shows negative time for a future start', (tester) async {
      final since = DateTime.now().add(const Duration(hours: 5));
      await tester.pumpWidget(_host(SmokeFreeTimer(since: since)));

      expect(find.text('0'), findsOneWidget);
      expect(find.text('00'), findsNWidgets(3));
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
        find.bySemanticsLabel(
          'Smoke-free for 3 days, 2 hours and 10 minutes',
        ),
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

    testWidgets('check-in card prompts, then confirms', (tester) async {
      await tester.pumpWidget(
        _host(
          CheckInCard(checkedIn: false, smokeFreeToday: null, onTap: () {}),
        ),
      );
      expect(find.text('Daily check-in'), findsOneWidget);

      await tester.pumpWidget(
        _host(CheckInCard(checkedIn: true, smokeFreeToday: true, onTap: () {})),
      );
      expect(find.text('Check-in complete'), findsOneWidget);
      expect(find.text('Today is marked smoke-free.'), findsOneWidget);
    });

    testWidgets('streak chip announces the streak', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(StreakChip(streak: 1, onTap: () {})),
      );

      expect(
        find.bySemanticsLabel('Smoke-free streak: 1 day'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
