import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/checkin/screens/daily_checkin_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/setup_settings_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/rescue/screens/rescue_screen.dart';
import '../../features/logging/screens/smoking_log_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/onboarding_repository.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>();
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
        pageBuilder: (context, state) =>
            _materialPage(state, const SmokingLogScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkIn,
        pageBuilder: (context, state) =>
            _materialPage(state, const DailyCheckInScreen()),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.setupSettings,
        pageBuilder: (context, state) =>
            _materialPage(state, const SetupSettingsScreen()),
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
