import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/core/widgets/savings_jar.dart';
import 'package:zeropuff/features/celebrations/milestone_celebration_controller.dart';
import 'package:zeropuff/features/celebrations/widgets/celebration_dialog.dart';

void main() {
  const event = CelebrationEvent(
    kind: CelebrationKind.milestone,
    key: '1_week',
    title: '1 week smoke-free',
    body: 'Seven days in a row.',
    duration: Duration(days: 7),
    icon: Symbols.emoji_events_rounded,
  );

  Future<({int Function() ticks, int Function() claims})> pump(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    var ticks = 0;
    var claims = 0;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          theme: AppTheme.light,
          home: CelebrationDialog(
            event: event,
            onShare: () {},
            onHoldTick: () => ticks += 1,
            onClaimed: () => claims += 1,
          ),
        ),
      ),
    );
    return (ticks: () => ticks, claims: () => claims);
  }

  testWidgets('the badge is claimed by holding it', (tester) async {
    final calls = await pump(tester);

    expect(find.text('Hold to claim it'), findsOneWidget);
    expect(find.text('1 week smoke-free'), findsNothing);
    expect(find.text('Keep going'), findsNothing);

    final hold = await tester.startGesture(
      tester.getCenter(find.byType(CustomPaint).last),
    );
    await tester.pump();
    for (var step = 0; step < 14; step++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await hold.up();
    await tester.pumpAndSettle();

    expect(calls.claims(), 1);
    expect(calls.ticks(), 3);
    expect(find.text('1 week smoke-free'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);
    expect(find.text('Share it'), findsOneWidget);
  });

  testWidgets('letting go early leaves it unclaimed', (tester) async {
    final calls = await pump(tester);

    final hold = await tester.startGesture(
      tester.getCenter(find.byType(CustomPaint).last),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await hold.up();
    await tester.pumpAndSettle();

    expect(calls.claims(), 0);
    expect(find.text('Hold to claim it'), findsOneWidget);
  });

  testWidgets('with reduced motion a press claims it at once', (tester) async {
    final calls = await pump(tester, reduceMotion: true);

    await tester.tap(find.byType(CustomPaint).last);
    await tester.pumpAndSettle();

    expect(calls.claims(), 1);
    expect(find.text('Keep going'), findsOneWidget);
  });

  testWidgets('dropped coins land and stay in the jar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            height: 160,
            child: CoinDropJar(fill: 0.5, drops: 3, hapticsEnabled: false),
          ),
        ),
      ),
    );

    SavingsJar jar() => tester.widget<SavingsJar>(find.byType(SavingsJar));

    await tester.pump(const Duration(milliseconds: 200));
    expect(jar().dropProgress, lessThan(1));
    await tester.pumpAndSettle();
    // The pile ends where it was meant to, with every coin down.
    expect(jar().fill, 0.5);
    expect(jar().dropCount, 3);
    expect(jar().dropProgress, 1);
  });
}
