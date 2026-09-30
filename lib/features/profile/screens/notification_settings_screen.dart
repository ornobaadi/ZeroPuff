import 'package:flutter/material.dart';
import '../../../core/errors/friendly_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/settings_tiles.dart';
import '../../../core/widgets/state_view.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/notifications/notification_service.dart';
import '../../home/providers/home_dashboard_provider.dart';

final editableNotificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
      return ref.watch(notificationPreferencesRepositoryProvider).load();
    });

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _saving = false;

  Future<void> _save(NotificationPreferences preferences) async {
    setState(() => _saving = true);
    try {
      var permissionDenied = false;
      if (preferences.dailyCheckInEnabled ||
          preferences.milestoneReminderEnabled ||
          preferences.streakProtectionEnabled ||
          preferences.dangerWindowEnabled) {
        permissionDenied = !await NotificationService.requestPermission();
      }

      final saved = await ref
          .read(notificationPreferencesRepositoryProvider)
          .save(preferences);
      final profile = await ref
          .read(onboardingRepositoryProvider)
          .loadCompletedProfile();
      final dashboard = ref.read(homeDashboardProvider).value;
      await NotificationService.reschedule(
        preferences: saved,
        quitDate: profile?.quitDate,
        smokingWindow: profile?.usualSmokingWindow,
        snapshot: dashboard == null
            ? const NotificationScheduleSnapshot()
            : NotificationScheduleSnapshot(
                todayCheckedIn: dashboard.todayCheckIn != null,
                smokeFreeDuration: dashboard.smokeFreeDuration,
                smokeFreeStreakDays: dashboard.smokeFreeStreakDays,
                checkInStreakDays: dashboard.checkInStreakDays,
                cigarettesAvoided: dashboard.cigarettesAvoided,
                moneySaved: dashboard.moneySaved,
                currencySymbol: dashboard.currencySymbol,
              ),
      );

      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref
            .read(profileRepositoryProvider)
            .upsertNotificationPreferences(userId: user.id, preferences: saved);
      }

      ref.invalidate(editableNotificationPreferencesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              permissionDenied
                  ? 'Saved, but notifications are blocked. Allow them in your phone settings to receive reminders.'
                  : 'Reminder settings saved.',
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _changeTime(NotificationPreferences preferences) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: preferences.dailyCheckInHour,
        minute: preferences.dailyCheckInMinute,
      ),
    );
    if (picked == null) {
      return;
    }
    await _save(
      preferences.copyWith(
        dailyCheckInHour: picked.hour,
        dailyCheckInMinute: picked.minute,
        dailyCheckInEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferences = ref.watch(editableNotificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: SafeArea(
        child: preferences.when(
          loading: () => const StateView.loading(),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(editableNotificationPreferencesProvider),
          ),
          data: (data) {
            final checkInTime = TimeOfDay(
              hour: data.dailyCheckInHour,
              minute: data.dailyCheckInMinute,
            ).format(context);

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Gentle reminders that adapt to your progress and pause when today is already recorded.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SettingsSection(
                        children: [
                          SettingsSwitchTile(
                            icon: Icons.fact_check_outlined,
                            title: 'Progress check-in',
                            subtitle:
                                'A personal nudge if today still needs a record.',
                            value: data.dailyCheckInEnabled,
                            onChanged: _saving
                                ? null
                                : (value) => _save(
                                    data.copyWith(dailyCheckInEnabled: value),
                                  ),
                          ),
                          if (data.dailyCheckInEnabled)
                            SettingsTile(
                              icon: Icons.access_time_rounded,
                              title: 'Check-in time',
                              trailing: checkInTime,
                              onTap: _saving ? null : () => _changeTime(data),
                            ),
                          SettingsSwitchTile(
                            icon: Icons.flag_outlined,
                            title: 'Milestones',
                            subtitle: 'Celebrate each smoke-free milestone.',
                            value: data.milestoneReminderEnabled,
                            onChanged: _saving
                                ? null
                                : (value) => _save(
                                    data.copyWith(
                                      milestoneReminderEnabled: value,
                                    ),
                                  ),
                          ),
                          SettingsSwitchTile(
                            icon: Icons.schedule_rounded,
                            title: 'Danger window',
                            subtitle:
                                'A small nudge before your usual smoking window starts.',
                            value: data.dangerWindowEnabled,
                            onChanged: _saving
                                ? null
                                : (value) => _save(
                                    data.copyWith(dangerWindowEnabled: value),
                                  ),
                          ),
                          SettingsSwitchTile(
                            icon: Icons.nightlight_round,
                            title: 'Streak protection',
                            subtitle:
                                'A later evening backup, only if today is blank.',
                            value: data.streakProtectionEnabled,
                            onChanged: _saving
                                ? null
                                : (value) => _save(
                                    data.copyWith(
                                      streakProtectionEnabled: value,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
