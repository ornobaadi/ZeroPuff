import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../env/app_config.dart';
import '../../services/local_database/local_database_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/supabase/supabase_service.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(isOptional: true);

    final config = AppConfig.fromEnv();
    await SupabaseService.initialize(config);
    await LocalDatabaseService.initialize();
    await NotificationService.initialize();
  }
}
