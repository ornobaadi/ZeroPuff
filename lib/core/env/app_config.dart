import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnv() {
    return AppConfig(
      supabaseUrl: dotenv.maybeGet(AppConstants.supabaseUrlKey) ?? '',
      supabaseAnonKey: dotenv.maybeGet(AppConstants.supabaseAnonKey) ?? '',
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
