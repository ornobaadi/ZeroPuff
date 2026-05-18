import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/controllers/google_sign_in_controller.dart';
import '../../../repositories/auth_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isGuest = user == null;

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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      isGuest
                          ? Icons.person_outline_rounded
                          : Icons.person_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    isGuest ? 'Guest mode' : user.email ?? 'Signed in',
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
            const _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Reminders',
              subtitle: 'Daily check-in and streak protection controls.',
              status: 'Phase 11',
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
                icon: Icons.logout_rounded,
                title: 'Sign out',
                subtitle: 'Keep local data on this device.',
                status: '',
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.signIn);
                  }
                },
              ),
            ],
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

  Future<void> _connectGoogle() async {
    setState(() => _isSyncing = true);
    try {
      await ref
          .read(googleSignInControllerProvider)
          .signInAndLinkGuestProfile();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;

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
              child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
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
