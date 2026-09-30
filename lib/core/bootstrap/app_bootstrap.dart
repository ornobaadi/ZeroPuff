import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../env/app_config.dart';
import '../../services/google/google_sign_in_service.dart';
import '../../services/device/device_identity_service.dart';
import '../../services/local_database/local_database_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/supabase/supabase_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(isOptional: true);

    final config = AppConfig.fromEnv();
    if (kDebugMode && !config.hasSupabaseConfig) {
      debugPrint(
        'ZeroPuff: Supabase is not configured (missing .env values). '
        'The app will run in guest-only mode.',
      );
    }

    // Local storage is required. Everything else is optional, so a failure in
    // one service must not stop the app from starting.
    await DeviceIdentityService.initialize();
    await LocalDatabaseService.initialize();

    await _optional('Google sign-in', () => GoogleSignInService.initialize(config));
    await _optional('Supabase', () => SupabaseService.initialize(config));
    await _optional('Notifications', NotificationService.initialize);
  }

  static Future<void> _optional(
    String name,
    Future<void> Function() step,
  ) async {
    try {
      await step();
    } on Object catch (error) {
      debugPrint('ZeroPuff: $name failed to initialize: $error');
    }
  }
}
