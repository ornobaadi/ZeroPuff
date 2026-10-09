import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'repositories/app_settings_repository.dart';
import 'services/notifications/notification_service.dart';

Future<void> main() async {
  try {
    await AppBootstrap.initialize();
  } on Object catch (error) {
    debugPrint('ZeroPuff: startup failed: $error');
    runApp(const _StartupErrorApp());
    return;
  }
  runApp(const ProviderScope(child: ZeroPuffApp()));
}

/// Shown when local storage cannot be opened, instead of a blank screen.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'ZeroPuff could not start. Please restart the app. '
                'If this keeps happening, reinstall it or contact support.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZeroPuffApp extends ConsumerStatefulWidget {
  const ZeroPuffApp({super.key});

  @override
  ConsumerState<ZeroPuffApp> createState() => _ZeroPuffAppState();
}

class _ZeroPuffAppState extends ConsumerState<ZeroPuffApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.openRoute.addListener(_openRequestedRoute);
    // A notification may have started the app before anything was listening.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openRequestedRoute());
  }

  @override
  void dispose() {
    NotificationService.openRoute.removeListener(_openRequestedRoute);
    super.dispose();
  }

  /// Opens the screen a tapped notification asked for. The router still
  /// decides whether the user may go there (sign-in, onboarding).
  void _openRequestedRoute() {
    final route = NotificationService.openRoute.value;
    if (route == null || !mounted) {
      return;
    }
    NotificationService.openRoute.value = null;
    final router = ref.read(appRouterProvider);
    if (router.state.matchedLocation != route) {
      router.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
