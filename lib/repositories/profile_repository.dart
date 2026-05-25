import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_data.dart';
import '../models/smoking_window_data.dart';
import 'notification_preferences_repository.dart';
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

    await _upsertPrimarySmokingWindow(
      userId: profile.userId,
      window: profile.usualSmokingWindow,
    );
  }

  Future<void> upsertNotificationPreferences({
    required String userId,
    required NotificationPreferences preferences,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client.from('notification_preferences').upsert({
      'user_id': userId,
      'daily_checkin_enabled': preferences.dailyCheckInEnabled,
      'daily_checkin_time':
          '${_two(preferences.dailyCheckInHour)}:${_two(preferences.dailyCheckInMinute)}:00',
      'milestone_reminder_enabled': preferences.milestoneReminderEnabled,
      'streak_protection_enabled': preferences.streakProtectionEnabled,
      'danger_window_enabled': preferences.dangerWindowEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteUserOwnedRows(String userId) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client
        .from('notification_preferences')
        .delete()
        .eq('user_id', userId);
    await client.from('profiles').delete().eq('id', userId);
  }

  Future<void> _upsertPrimarySmokingWindow({
    required String userId,
    required SmokingWindowData window,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    final existing = await client
        .from('user_smoking_windows')
        .select('id')
        .eq('user_id', userId)
        .eq('is_primary', true)
        .maybeSingle();
    final payload = {
      'user_id': userId,
      'label': window.label,
      'start_time': window.startTimeSql,
      'end_time': window.endTimeSql,
      'days_of_week': window.daysOfWeek,
      'enabled': window.enabled,
      'is_primary': true,
      'source': window.source,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final id = existing?['id']?.toString();
    if (id == null) {
      await client.from('user_smoking_windows').insert(payload);
    } else {
      await client.from('user_smoking_windows').update(payload).eq('id', id);
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
