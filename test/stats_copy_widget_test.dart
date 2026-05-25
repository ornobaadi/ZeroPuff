import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeropuff/features/celebrations/milestone_celebration_controller.dart';
import 'package:zeropuff/features/home/providers/home_dashboard_provider.dart';
import 'package:zeropuff/features/home/screens/home_screen.dart';
import 'package:zeropuff/features/profile/screens/app_info_screen.dart';
import 'package:zeropuff/features/progress/screens/progress_screen.dart';

void main() {
  testWidgets('home stats grid includes life won back', (tester) async {
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

    expect(find.text('Life won back'), findsOneWidget);
    expect(find.text('Money won back'), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
  });

  testWidgets('progress quick stats include life won back', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWithValue(AsyncData(_dashboardData())),
          recentCheckInsProvider.overrideWith((ref) async => []),
          recentCravingsProvider.overrideWith((ref) async => []),
          unlockedAchievementsProvider.overrideWith((ref) async => {}),
        ],
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Life won back'), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
    expect(find.text('Money won back'), findsOneWidget);
  });

  testWidgets('app info explains life won back source and caveat', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AppInfoScreen()));

    expect(find.text('Stats and sources'), findsOneWidget);
    expect(find.textContaining('Life won back'), findsOneWidget);
    expect(
      find.textContaining('not personal medical predictions'),
      findsOneWidget,
    );
  });
}

HomeDashboardData _dashboardData() {
  return const HomeDashboardData(
    smokeFreeDuration: Duration(days: 5),
    cigarettesAvoided: 72,
    moneySaved: 43.2,
    lifeMinutesWonBack: 1440,
    lifeWonBackDuration: Duration(days: 1),
    lifeWonBackLabel: '1 day',
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
