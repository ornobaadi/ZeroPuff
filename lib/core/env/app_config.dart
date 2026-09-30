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
      supabaseUrl: _read(
        AppConstants.supabaseUrlKey,
        const String.fromEnvironment('SUPABASE_URL'),
      ),
      supabaseAnonKey: _read(
        AppConstants.supabaseAnonKey,
        const String.fromEnvironment('SUPABASE_ANON_KEY'),
      ),
      googleWebClientId: _read(
        AppConstants.googleWebClientIdKey,
        const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
      ),
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleWebClientId;

  bool get hasSupabaseConfig =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;

  /// Reads [key] from the bundled `.env`, falling back to the value passed
  /// with `--dart-define`. `String.fromEnvironment` only works with compile-time
  /// constants, so each define is read with a literal key by the caller.
  static String _read(String key, String dartDefine) {
    final fromEnv = dotenv.maybeGet(key)?.trim() ?? '';
    return fromEnv.isNotEmpty ? fromEnv : dartDefine.trim();
  }
}
