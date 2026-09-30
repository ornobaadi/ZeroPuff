import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeropuff/core/theme/app_theme.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/features/profile/screens/app_info_screen.dart';
import 'package:zeropuff/features/progress/screens/progress_screen.dart';

const _sizes = <String, Size>{
  'compact phone': Size(360, 640),
  'large phone': Size(412, 915),
  'foldable / medium': Size(700, 900),
  'tablet / expanded': Size(1024, 768),
  'landscape phone': Size(800, 360),
};

HomeDashboardData _data() => const HomeDashboardData(
  smokeFreeDuration: Duration(days: 5),
  cigarettesAvoided: 72,
  moneySaved: 43.2,
  currencySymbol: r'$',
  cigarettesPerDay: 15,
  packPrice: 12,
  packSize: 20,
  smokeFreeDays: 5,
  smokeFreeStreakDays: 5,
  checkInStreakDays: 2,
  honestyStreakDays: 2,
  resistanceStreak: 0,
);

Widget _progress({required double textScale, Brightness? dark}) {
  return ProviderScope(
    overrides: [
      homeDashboardProvider.overrideWithValue(AsyncData(_data())),
      recentCheckInsProvider.overrideWith((ref) async => []),
      recentCravingsProvider.overrideWith((ref) async => []),
      unlockedAchievementsProvider.overrideWith((ref) async => {}),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const ProgressScreen(),
    ),
  );
}

void main() {
  for (final entry in _sizes.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Progress lays out at ${entry.key}, text ×$scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(entry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_progress(textScale: scale));
        await tester.pumpAndSettle();

        // Any RenderFlex overflow is reported as a test exception.
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('App info meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppInfoScreen()),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('Progress meets guidelines in light and dark', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(_progress(textScale: 1, dark: brightness));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    handle.dispose();
  });
}
