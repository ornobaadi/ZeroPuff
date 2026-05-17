import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleWebClientId,
  });

  factory AppConfig.fromEnv() {
    return AppConfig(
      supabaseUrl: _read(AppConstants.supabaseUrlKey),
      supabaseAnonKey: _read(AppConstants.supabaseAnonKey),
      googleWebClientId: _read(AppConstants.googleWebClientIdKey),
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;

  bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;

  static String _read(String key) {
    return dotenv.maybeGet(key) ?? String.fromEnvironment(key).trim();
  }
}
