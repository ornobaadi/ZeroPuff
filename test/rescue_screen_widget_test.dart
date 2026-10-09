import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/rescue/screens/rescue_screen.dart';
import 'package:zeropuff/features/rescue/widgets/breath_orb.dart';

void main() {
  Future<void> pumpRescue(WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const RescueScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('rescue opens straight into breathing, with no form first', (
    tester,
  ) async {
    await pumpRescue(tester);

    expect(find.text('Breathe with it'), findsOneWidget);
    expect(find.byType(BreathOrb), findsOneWidget);
    expect(find.text('Hold to breathe in'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('holding and releasing the orb takes one breath', (tester) async {
    await pumpRescue(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(BreathOrb)),
    );
    await tester.pump();
    expect(find.text('Breathe in'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await gesture.up();
    await tester.pump();
    expect(find.text('Breathe out'), findsOneWidget);

    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    expect(find.text('Hold to breathe in'), findsOneWidget);
    expect(find.bySemanticsLabel('Breath 1 of 6'), findsOneWidget);
  });

  testWidgets('a strong urge leads to other tools, and an easier one to a win', (
    tester,
  ) async {
    await pumpRescue(tester);

    await tester.tap(find.text('Skip ahead'));
    await tester.pumpAndSettle();
    expect(find.text('How is the urge now?'), findsOneWidget);

    await tester.tap(find.text('Still strong'));
    await tester.pumpAndSettle();
    expect(find.text('Let us try something else'), findsOneWidget);

    await tester.tap(find.text('Read your reason'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I read it'));
    await tester.pumpAndSettle();
    expect(find.text('How is the urge now?'), findsOneWidget);

    await tester.tap(find.text('It passed'));
    await tester.pumpAndSettle();
    expect(find.text('Craving beaten'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
