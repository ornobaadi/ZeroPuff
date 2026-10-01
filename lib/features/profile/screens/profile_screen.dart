import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/friendly_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/settings_tiles.dart';
import '../../../repositories/account_repository.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../services/haptics/haptic_service.dart';
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
    final themeMode = ref.watch(themeModeControllerProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            // Clears the floating navigation bar the page scrolls under.
            AppSpacing.pagePadding + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IdentityCard(
                    isGuest: isGuest,
                    displayName: displayName,
                    avatarUrl: avatarUrl,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SettingsSection(
                    title: 'Preferences',
                    children: [
                      SettingsTile(
                        icon: Symbols.palette_rounded,
                        title: 'Appearance',
                        subtitle: 'System, light or dark mode',
                        trailing: _themeModeLabel(themeMode),
                        onTap: () => _openRoute(AppRoutes.appearanceSettings),
                      ),
                      SettingsSwitchTile(
                        icon: Symbols.vibration_rounded,
                        title: 'Haptics',
                        subtitle:
                            'Gentle taps for rescue steps and key actions',
                        value: hapticsEnabled,
                        onChanged: (enabled) async {
                          await ref
                              .read(hapticsEnabledControllerProvider.notifier)
                              .setEnabled(enabled);
                          await HapticService.light(enabled: enabled);
                        },
                      ),
                      SettingsTile(
                        icon: Symbols.notifications_rounded,
                        title: 'Reminders',
                        subtitle: 'Progress, milestone and evening nudges',
                        onTap: () => _openRoute(AppRoutes.notificationSettings),
                      ),
                      SettingsTile(
                        icon: Symbols.tune_rounded,
                        title: 'Setup details',
                        subtitle: 'Quit date, smoking pace, currency, triggers',
                        onTap: () => _openRoute(AppRoutes.setupSettings),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SettingsSection(
                    title: 'Backup',
                    children: [
                      SettingsTile(
                        icon: Symbols.cloud_sync_rounded,
                        title: 'Account sync',
                        subtitle: isGuest
                            ? 'Optional. Guest mode stays available.'
                            : 'Connected to Google for backup and restore.',
                        trailing: isGuest
                            ? (_isSyncing ? 'Opening…' : null)
                            : 'Connected',
                        onTap: isGuest && !_isSyncing
                            ? () {
                                _lightHaptic();
                                _connectGoogle();
                              }
                            : null,
                      ),
                      if (!isGuest)
                        SettingsTile(
                          icon: Symbols.sync_rounded,
                          title: 'Sync now',
                          subtitle: pendingSync.when(
                            data: (count) => count == 0
                                ? 'Everything on this device is backed up.'
                                : '$count change${count == 1 ? '' : 's'} waiting to back up.',
                            loading: () => 'Checking for changes…',
                            error: (_, _) => 'Could not check for changes.',
                          ),
                          trailing: _isManualSyncing ? 'Syncing…' : null,
                          onTap: _isManualSyncing
                              ? null
                              : () {
                                  _lightHaptic();
                                  _syncNow();
                                },
                        ),
                      if (!isGuest)
                        SettingsTile(
                          icon: Symbols.logout_rounded,
                          title: 'Sign out',
                          subtitle:
                              'Your progress stays backed up in your account.',
                          onTap: () {
                            _mediumHaptic();
                            _signOut();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SettingsSection(
                    title: 'About',
                    children: [
                      SettingsTile(
                        icon: Symbols.info_rounded,
                        title: 'App info and safety',
                        subtitle: 'Version, privacy note and disclaimer',
                        onTap: () => _openRoute(AppRoutes.appInfo),
                      ),
                      if (AppConstants.privacyPolicyUrl.isNotEmpty)
                        SettingsTile(
                          icon: Symbols.policy_rounded,
                          title: 'Privacy policy',
                          subtitle: 'Opens in your browser',
                          onTap: () => launchUrl(
                            Uri.parse(AppConstants.privacyPolicyUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SettingsSection(
                    title: 'Your data',
                    children: [
                      SettingsTile(
                        icon: Symbols.delete_rounded,
                        title: isGuest ? 'Delete local data' : 'Delete account',
                        subtitle: isGuest
                            ? 'Erase guest progress from this device.'
                            : 'Permanently delete your account and all backed-up data.',
                        destructive: true,
                        onTap: () {
                          _mediumHaptic();
                          _confirmDeleteAccount(isGuest);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Center(
                    child: Text(
                      '${AppConstants.appName} ${AppConstants.appVersionLabel}',
                      style: theme.textTheme.labelMedium?.copyWith(
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

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _openRoute(String route) {
    HapticService.selection(enabled: _hapticsEnabled);
    context.push(route);
  }

  void _lightHaptic() {
    HapticService.light(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
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
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// Backs up pending changes, then signs out and clears this device.
  ///
  /// Local data is cleared so the next person who signs in cannot inherit (or
  /// upload into their own account) the previous user's logs.
  Future<void> _signOut() async {
    try {
      final result = await ref
          .read(syncServiceProvider)
          .syncPending(limit: 500);
      if (result.remaining > 0) {
        if (!mounted) {
          return;
        }
        final proceed = await showConfirmDialog(
          context,
          title: 'Some changes are not backed up',
          message:
              '${result.remaining} change${result.remaining == 1 ? '' : 's'} could not be backed up. '
              'If you sign out now they will be lost.',
          confirmLabel: 'Sign out anyway',
          cancelLabel: 'Stay signed in',
          destructive: true,
        );
        if (!proceed) {
          return;
        }
      }
      await NotificationService.cancelScheduledReminders();
      await ref.read(accountRepositoryProvider).deleteLocalData();
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(currentUserProvider);
      ref.invalidate(homeBaselineProvider);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(pendingSyncCountProvider);
      if (mounted) {
        context.go(AppRoutes.signIn);
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
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
        ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isManualSyncing = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount(bool isGuest) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Symbols.delete_rounded,
      title: isGuest ? 'Delete ZeroPuff data?' : 'Delete your account?',
      message: isGuest
          ? 'This removes your guest progress, logs, check-ins and settings from this device.'
          : 'This permanently deletes your ZeroPuff account and all backed-up data, and removes local data from this device. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) {
      return;
    }

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(profileRepositoryProvider).deleteAccount();
      }
      await NotificationService.cancelScheduledReminders();
      await ref.read(accountRepositoryProvider).deleteLocalData();
      try {
        // The account may already be gone server-side, so a sign-out failure
        // here must not hide the successful deletion.
        await ref.read(authRepositoryProvider).signOut();
      } on Object {
        // Ignored on purpose.
      }
      ref.invalidate(currentUserProvider);
      ref.invalidate(homeBaselineProvider);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(pendingSyncCountProvider);
      if (mounted) {
        context.go(AppRoutes.signIn);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGuest ? 'ZeroPuff data deleted.' : 'Your account was deleted.',
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
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.isGuest,
    required this.displayName,
    required this.avatarUrl,
  });

  final bool isGuest;
  final String displayName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      style: isGuest ? AppCardStyle.tonal : AppCardStyle.filled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileAvatar(
            isGuest: isGuest,
            avatarUrl: avatarUrl,
            displayName: displayName,
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            header: true,
            child: Text(
              isGuest ? 'Guest mode' : displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isGuest ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isGuest
                ? 'Your progress is stored on this device. Connect Google under Backup to keep it safe and restore it on another device.'
                : 'Google is connected. Your supported progress can be restored after a reinstall or on another device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isGuest
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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
    final scheme = theme.colorScheme;
    final initials = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first.toUpperCase();

    return ExcludeSemantics(
      child: CircleAvatar(
        radius: 28,
        backgroundColor: isGuest ? scheme.surface : scheme.primaryContainer,
        backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl!),
        onBackgroundImageError: avatarUrl == null ? null : (_, _) {},
        child: avatarUrl == null
            ? isGuest
                  ? Icon(Symbols.person_rounded, color: scheme.primary)
                  : Text(
                      initials,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    )
            : null,
      ),
    );
  }
}
