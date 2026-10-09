import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/core/widgets/app_dialog.dart';
import 'package:zeropuff/features/profile/screens/setup_settings_screen.dart';
import 'package:zeropuff/models/profile_data.dart';
import 'package:zeropuff/models/smoking_window_data.dart';

void main() {
  testWidgets('setup details shows the form above the save button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          editableProfileProvider.overrideWith(
            (ref) async => ProfileData(
              userId: 'guest',
              displayName: 'Guest',
              quitDate: DateTime(2026, 10, 1),
              cigarettesPerDay: 12,
              packPrice: 340,
              packSize: 20,
              currencyCode: 'BDT',
              currencySymbol: '৳',
              triggers: const ['stress'],
              usualSmokingWindow: SmokingWindowData.defaultWindow(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SetupSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quit date'), findsOneWidget);
    expect(find.text('Cigarettes per day'), findsOneWidget);

    // The bug this guards against: the save bar filled the screen, sat at the
    // top and left the form with no height.
    final form = tester.getTopLeft(find.text('Quit date'));
    final save = tester.getTopLeft(find.text('Save changes'));
    expect(save.dy, greaterThan(form.dy));
    expect(save.dy, greaterThan(600));
  });

  testWidgets('dialog buttons sit side by side at equal width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppDialog(
            title: 'Delete ZeroPuff data?',
            message: 'This removes your progress from this device.',
            primaryLabel: 'Delete',
            onPrimary: () {},
            destructive: true,
          ),
        ),
      ),
    );

    final cancel = tester.getRect(find.widgetWithText(OutlinedButton, 'Cancel'));
    final delete = tester.getRect(find.widgetWithText(FilledButton, 'Delete'));
    expect(cancel.top, delete.top);
    expect(cancel.width, moreOrLessEquals(delete.width, epsilon: 0.5));
    expect(cancel.right, lessThan(delete.left));
  });
}
