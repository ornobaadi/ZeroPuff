import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_data.dart';
import '../services/supabase/supabase_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient? _client;

  Future<bool> onboardingCompleted(String userId) async {
    final client = _client;
    if (client == null) {
      return false;
    }

    final row = await client
        .from('profiles')
        .select('onboarding_completed')
        .eq('id', userId)
        .maybeSingle();
    return row?['onboarding_completed'] == true;
  }

  Future<void> upsertProfile(ProfileData profile) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client.from('profiles').upsert({
      'id': profile.userId,
      'display_name': profile.displayName,
      'avatar_url': profile.avatarUrl,
      'quit_date': profile.quitDate.toIso8601String(),
      'cigarettes_per_day': profile.cigarettesPerDay,
      'pack_price': profile.packPrice,
      'pack_size': profile.packSize,
      'currency_code': profile.currencyCode,
      'currency_symbol': profile.currencySymbol,
      'triggers': profile.triggers,
      'quit_reason': profile.quitReason,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await client.from('notification_preferences').upsert({
      'user_id': profile.userId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
