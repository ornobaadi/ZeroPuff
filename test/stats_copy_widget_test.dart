import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeropuff/features/celebrations/milestone_celebration_controller.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/features/home/screens/home_screen.dart';
import 'package:zeropuff/features/profile/screens/app_info_screen.dart';
import 'package:zeropuff/features/progress/providers/milestone_providers.dart';
import 'package:zeropuff/features/progress/screens/progress_screen.dart';

void main() {
  testWidgets('home shows the money jar in place of a stats grid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWithValue(AsyncData(_dashboardData())),
          milestoneCelebrationProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          home: HomeScreen(enableNotificationRefresh: false),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MONEY KEPT'), findsOneWidget);
    expect(find.text('72 cigarettes not smoked'), findsOneWidget);
    expect(find.text('I slipped'), findsOneWidget);
    expect(find.text('Time smoke-free'), findsNothing);
    expect(find.text('Need to log?'), findsNothing);
  });

  testWidgets('progress quick stats say something about today', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWithValue(AsyncData(_dashboardData())),
          recentCheckInsProvider.overrideWith((ref) async => []),
          recentCravingsProvider.overrideWith((ref) async => []),
          unlockedMilestonesProvider.overrideWith((ref) async => {}),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Money kept'), findsOneWidget);
    expect(find.text('Cravings beaten'), findsOneWidget);
    expect(find.text('Best run'), findsOneWidget);
    expect(find.text('Time not smoking'), findsOneWidget);
    // 72 cigarettes at about six minutes each.
    expect(find.text('7 h'), findsOneWidget);
    expect(find.text('Check-ins'), findsNothing);
  });

  testWidgets('app info shows the not-medical-advice disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AppInfoScreen()));

    expect(find.textContaining('not medical advice'), findsOneWidget);
  });
}

HomeDashboardData _dashboardData() {
  return const HomeDashboardData(
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
}
