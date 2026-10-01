import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/onboarding/screens/onboarding_screen.dart';

Future<void> _pumpOnboarding(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: const OnboardingScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapPrimary(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on a welcome page without a progress bar', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    expect(
      find.text('Opening this took\ncourage.', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('walks through every setup step', (tester) async {
    await _pumpOnboarding(tester);

    await _tapPrimary(tester, 'Get started');
    expect(
      find.text('When should ZeroPuff start counting?', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('1 of 5'), findsOneWidget);

    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();
    await _tapPrimary(tester, 'Continue');

    expect(
      find.text('Make your progress measurable', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('2 of 5'), findsOneWidget);
    await _tapPrimary(tester, 'Continue');

    expect(
      find.text('When and why do cravings show up?', findRichText: true),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Stressed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stressed'));
    await tester.pumpAndSettle();
    await _tapPrimary(tester, 'Continue');

    expect(
      find.text('Leave yourself one honest reason', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Skip for now'), findsOneWidget);
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(
      find.text('Want a nudge at the right moment?', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('5 of 5'), findsOneWidget);
    expect(find.text('Turn on reminders'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('blocks continuing with zero cigarettes per day', (tester) async {
    await _pumpOnboarding(tester);
    await _tapPrimary(tester, 'Get started');
    await _tapPrimary(tester, 'Continue');

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('Decrease Cigarettes per day'));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 1 cigarette per day.'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byTooltip('Increase Cigarettes per day'));
    await tester.pumpAndSettle();

    expect(find.text('Enter at least 1 cigarette per day.'), findsNothing);
    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets('requires a trigger before leaving the routine step', (
    tester,
  ) async {
    await _pumpOnboarding(tester);
    await _tapPrimary(tester, 'Get started');
    await _tapPrimary(tester, 'Continue');
    await _tapPrimary(tester, 'Continue');

    expect(
      find.text('Pick at least one so we can tailor your rescue.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Back returns to the previous step', (tester) async {
    await _pumpOnboarding(tester);
    await _tapPrimary(tester, 'Get started');
    await _tapPrimary(tester, 'Continue');

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(
      find.text('When should ZeroPuff start counting?', findRichText: true),
      findsOneWidget,
    );
  });
}
