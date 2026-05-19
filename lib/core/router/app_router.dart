import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/checkin/screens/daily_checkin_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/journal/screens/quit_journal_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../features/profile/screens/setup_settings_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/recovery/screens/relapse_recovery_screen.dart';
import '../../features/rescue/screens/rescue_screen.dart';
import '../../features/logging/screens/smoking_log_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/stats/screens/progress_detail_screens.dart';
import '../../features/stats/screens/streak_details_screen.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/onboarding_repository.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>();
final shellNavigatorJournalKey = GlobalKey<NavigatorState>();
final shellNavigatorProgressKey = GlobalKey<NavigatorState>();
final shellNavigatorProfileKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      final onboardingRepository = ref.read(onboardingRepositoryProvider);
      final completedProfile = await onboardingRepository
          .loadCompletedProfile();
      final hasCompletedOnboarding = completedProfile != null;

      final user = ref.read(currentUserProvider);
      final isSignedIn = user != null;

      final location = state.matchedLocation;
      final isSignInRoute = location == AppRoutes.signIn;
      final isOnboardingRoute = location == AppRoutes.onboarding;

      if (hasCompletedOnboarding) {
        if (isOnboardingRoute) {
          return AppRoutes.home;
        }

        if (isSignInRoute && isSignedIn) {
          return AppRoutes.home;
        }

        return null;
      }

      if (isOnboardingRoute) {
        return null;
      }

      if (isSignInRoute) {
        return isSignedIn ? AppRoutes.onboarding : null;
      }

      return isSignedIn ? AppRoutes.onboarding : AppRoutes.signIn;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) =>
            _materialPage(state, const SignInScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _materialPage(state, const OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    _noTransitionPage(state, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorJournalKey,
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                pageBuilder: (context, state) =>
                    _noTransitionPage(state, const QuitJournalScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProgressKey,
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                pageBuilder: (context, state) =>
                    _noTransitionPage(state, const ProgressScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) =>
                    _noTransitionPage(state, const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.rescue,
        pageBuilder: (context, state) =>
            _materialPage(state, const RescueScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.logging,
        pageBuilder: (context, state) => _materialPage(
          state,
          SmokingLogScreen(logId: state.uri.queryParameters['logId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.recovery,
        pageBuilder: (context, state) => _materialPage(
          state,
          RelapseRecoveryScreen(logId: state.uri.queryParameters['logId']),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkIn,
        pageBuilder: (context, state) =>
            _materialPage(state, const DailyCheckInScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.streakDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const StreakDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.smokeFreeDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const SmokeFreeDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.savingsDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const SavingsDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.avoidedDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const AvoidedDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.cravingAnalysis,
        pageBuilder: (context, state) =>
            _materialPage(state, const CravingAnalysisScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.healthDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const HealthMilestoneDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.achievementsDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const AchievementsDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkInDetails,
        pageBuilder: (context, state) =>
            _materialPage(state, const CheckInDetailsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.setupSettings,
        pageBuilder: (context, state) =>
            _materialPage(state, const SetupSettingsScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notificationSettings,
        pageBuilder: (context, state) =>
            _materialPage(state, const NotificationSettingsScreen()),
      ),
    ],
  );
});

Page<void> _materialPage(GoRouterState state, Widget child) {
  return MaterialPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    child: child,
  );
}

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    child: child,
  );
}
