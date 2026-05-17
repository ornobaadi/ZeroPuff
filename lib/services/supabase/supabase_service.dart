import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env/app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnv());

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return SupabaseService.clientOrNull;
});

class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;

  static SupabaseClient? get clientOrNull {
    if (!_initialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize(AppConfig config) async {
    if (!config.hasSupabaseConfig || _initialized) {
      return;
    }

    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
    _initialized = true;
  }
}
