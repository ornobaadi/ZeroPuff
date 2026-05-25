import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
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
      if (preferences.dailyCheckInEnabled ||
          preferences.milestoneReminderEnabled ||
          preferences.streakProtectionEnabled ||
          preferences.dangerWindowEnabled) {
        await NotificationService.requestPermission();
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
          const SnackBar(content: Text('Notification settings saved.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
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
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: preferences.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Text(error.toString()),
          ),
          data: (data) {
            final checkInTime = TimeOfDay(
              hour: data.dailyCheckInHour,
              minute: data.dailyCheckInMinute,
            ).format(context);

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gentle reminders',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Local reminders adapt to your progress and pause when today is already recorded.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _ReminderTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Progress check-in',
                  subtitle:
                      'A personal nudge around $checkInTime if today still needs a record.',
                  value: data.dailyCheckInEnabled,
                  saving: _saving,
                  onChanged: (value) =>
                      _save(data.copyWith(dailyCheckInEnabled: value)),
                  trailing: TextButton(
                    onPressed: _saving ? null : () => _changeTime(data),
                    child: Text(checkInTime),
                  ),
                ),
                const SizedBox(height: AppSpacing.componentGap),
                _ReminderTile(
                  icon: Icons.flag_outlined,
                  title: 'Health milestones',
                  subtitle: 'Celebrate the next body-recovery marker.',
                  value: data.milestoneReminderEnabled,
                  saving: _saving,
                  onChanged: (value) =>
                      _save(data.copyWith(milestoneReminderEnabled: value)),
                ),
                const SizedBox(height: AppSpacing.componentGap),
                _ReminderTile(
                  icon: Icons.schedule_rounded,
                  title: 'Danger window',
                  subtitle:
                      'A small nudge before your usual smoking window starts.',
                  value: data.dangerWindowEnabled,
                  saving: _saving,
                  onChanged: (value) =>
                      _save(data.copyWith(dangerWindowEnabled: value)),
                ),
                const SizedBox(height: AppSpacing.componentGap),
                _ReminderTile(
                  icon: Icons.nightlight_round,
                  title: 'Streak protection',
                  subtitle: 'A later evening backup only if today is blank.',
                  value: data.streakProtectionEnabled,
                  saving: _saving,
                  onChanged: (value) =>
                      _save(data.copyWith(streakProtectionEnabled: value)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.saving,
    required this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool saving;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
          Switch(value: value, onChanged: saving ? null : onChanged),
        ],
      ),
    );
  }
}
