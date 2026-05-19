import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../repositories/account_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../services/sync/sync_service.dart';
import '../../auth/controllers/google_sign_in_controller.dart';
import '../../home/providers/home_dashboard_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSyncing = false;
  bool _isManualSyncing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isGuest = user == null;
    final displayName = _displayName(user);
    final avatarUrl = _avatarUrl(user);
    final pendingSync = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: isGuest
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isGuest
                      ? AppColors.primary.withValues(alpha: 0.18)
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileAvatar(
                    isGuest: isGuest,
                    avatarUrl: avatarUrl,
                    displayName: displayName,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    isGuest ? 'Guest mode' : displayName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isGuest
                        ? 'Explore first. Your local progress can be attached to Google when account sync is fully enabled.'
                        : 'Google is connected. Sync controls and account deletion arrive in the settings phase.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Settings', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.tune_rounded,
              title: 'Setup details',
              subtitle: 'Quit date, daily baseline, currency, and triggers.',
              status: 'Edit',
              onTap: () => context.push(AppRoutes.setupSettings),
            ),
            const SizedBox(height: AppSpacing.componentGap),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Reminders',
              subtitle: 'Daily check-in, milestone, and 11 PM nudges.',
              status: 'Edit',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            const SizedBox(height: AppSpacing.componentGap),
            _SettingsTile(
              icon: Icons.cloud_sync_outlined,
              title: 'Account sync',
              subtitle: isGuest
                  ? 'Optional. Guest mode remains available.'
                  : 'Connected to Google.',
              status: isGuest
                  ? (_isSyncing ? 'Opening…' : 'Optional')
                  : 'Connected',
              onTap: isGuest && !_isSyncing ? _connectGoogle : null,
            ),
            if (!isGuest) ...[
              const SizedBox(height: AppSpacing.componentGap),
              _SettingsTile(
                icon: Icons.sync_rounded,
                title: 'Sync now',
                subtitle: pendingSync.when(
                  data: (count) => count == 0
                      ? 'Everything local is caught up.'
                      : '$count local change${count == 1 ? '' : 's'} waiting.',
                  loading: () => 'Checking local changes.',
                  error: (_, _) => 'Could not check local changes.',
                ),
                status: _isManualSyncing ? 'Syncing' : 'Retry',
                onTap: _isManualSyncing ? null : _syncNow,
              ),
            ],
            if (!isGuest) ...[
              const SizedBox(height: AppSpacing.componentGap),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                subtitle: 'Keep local data on this device.',
                status: '',
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  ref.invalidate(currentUserProvider);
                  ref.invalidate(homeBaselineProvider);
                  ref.invalidate(homeDashboardProvider);
                },
              ),
            ],
            const SizedBox(height: AppSpacing.componentGap),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete local data',
              subtitle: isGuest
                  ? 'Erase guest progress from this device.'
                  : 'Erase local data and remove synced profile rows.',
              status: '',
              destructive: true,
              onTap: () => _confirmDeleteAccount(isGuest),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.accentCraving.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.accentCraving.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.accentCraving,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'ZeroPuff should never shame you into using it. Account features are for backup and sync, not for permission to start.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(dynamic user) {
    if (user == null) {
      return 'Guest mode';
    }
    final metadata = user.userMetadata as Map<String, dynamic>? ?? const {};
    for (final key in ['full_name', 'name', 'display_name']) {
      final value = metadata[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    final email = user.email?.toString();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Signed in';
  }

  String? _avatarUrl(dynamic user) {
    if (user == null) {
      return null;
    }
    final metadata = user.userMetadata as Map<String, dynamic>? ?? const {};
    for (final key in ['avatar_url', 'picture']) {
      final value = metadata[key]?.toString().trim();
      if (value != null && value.startsWith('http')) {
        return value;
      }
    }
    return null;
  }

  Future<void> _connectGoogle() async {
    setState(() => _isSyncing = true);
    try {
      final outcome = await ref
          .read(googleSignInControllerProvider)
          .signInAndLinkGuestProfile();
      if (mounted) {
        final message = outcome.restoredRows > 0
            ? 'Google connected. Restored ${outcome.restoredRows} synced rows.'
            : 'Google connected. Backup is ready.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _syncNow() async {
    setState(() => _isManualSyncing = true);
    try {
      final result = await ref
          .read(syncServiceProvider)
          .syncPending(limit: 100);
      final restore = await ref
          .read(syncServiceProvider)
          .restoreRemoteSnapshot(replaceLocal: result.remaining == 0);
      ref.invalidate(pendingSyncCountProvider);
      ref.invalidate(homeBaselineProvider);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(todayCheckInProvider);
      ref.invalidate(recentCheckInsProvider);
      ref.invalidate(recentSmokingLogsProvider);
      ref.invalidate(recentCravingsProvider);
      ref.invalidate(latestSmokeAtProvider);
      if (mounted) {
        final message = result.skipped
            ? 'Sign in to sync local changes.'
            : result.failed > 0
            ? 'Synced ${result.succeeded}. ${result.failed} still need retry.'
            : result.remaining > 0
            ? 'Synced ${result.succeeded}. ${result.remaining} still queued.'
            : restore.restoredRows > 0
            ? 'Sync complete. Restored ${restore.restoredRows} synced rows.'
            : 'Sync complete.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isManualSyncing = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount(bool isGuest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ZeroPuff data?'),
        content: Text(
          isGuest
              ? 'This removes your guest progress, logs, check-ins, and settings from this device.'
              : 'This removes local data and attempts to delete your synced profile/settings rows. Full auth-user deletion needs the later secure Edge Function.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(profileRepositoryProvider).deleteUserOwnedRows(user.id);
      }
      await NotificationService.cancelScheduledReminders();
      await ref.read(accountRepositoryProvider).deleteLocalData();
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(currentUserProvider);
      ref.invalidate(homeBaselineProvider);
      ref.invalidate(homeDashboardProvider);
      if (mounted) {
        context.go(AppRoutes.signIn);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ZeroPuff data deleted.')));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.isGuest,
    required this.avatarUrl,
    required this.displayName,
  });

  final bool isGuest;
  final String? avatarUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first.toUpperCase();

    return CircleAvatar(
      radius: 30,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl!),
      onBackgroundImageError: avatarUrl == null ? null : (_, _) {},
      child: avatarUrl == null
          ? isGuest
                ? Icon(
                    Icons.person_outline_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  )
                : Text(
                    initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  )
          : null,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: destructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: destructive ? theme.colorScheme.error : null,
                    ),
                  ),
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
            const SizedBox(width: AppSpacing.sm),
            Text(
              status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
