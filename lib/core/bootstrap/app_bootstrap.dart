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
    await GoogleSignInService.initialize(config);
    await SupabaseService.initialize(config);
    await DeviceIdentityService.initialize();
    await LocalDatabaseService.initialize();
    await NotificationService.initialize();
  }
}
