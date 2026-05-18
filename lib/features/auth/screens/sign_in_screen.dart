import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/profile_data.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../repositories/profile_repository.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.72,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.air_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Private by default',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(AppConstants.appName, style: theme.textTheme.displayLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppConstants.appTagline,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _PromiseCard(
              icon: Icons.timer_outlined,
              title: 'Two minutes first',
              body: 'Open the app during a craving and delay the decision.',
            ),
            const SizedBox(height: AppSpacing.componentGap),
            const _PromiseCard(
              icon: Icons.storage_rounded,
              title: 'Use it before an account',
              body: 'Your setup stays on this device until you decide to sync.',
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.onboarding),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Start as guest'),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _isSigningIn ? null : _signIn,
              icon: _isSigningIn
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                _isSigningIn ? 'Opening Google' : 'Continue with Google',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Sign in only when you want backup and cross-device sync. Account-only features will ask at the moment they need it.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _isSigningIn = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      final user = ref.read(currentUserProvider);
      final localProfile = await ref
          .read(onboardingRepositoryProvider)
          .loadCompletedProfile();
      if (user != null && localProfile != null) {
        final linkedProfile = ProfileData(
          userId: user.id,
          displayName:
              user.userMetadata?['full_name']?.toString() ??
              user.email ??
              localProfile.displayName,
          avatarUrl: user.userMetadata?['avatar_url']?.toString(),
          quitDate: localProfile.quitDate,
          cigarettesPerDay: localProfile.cigarettesPerDay,
          packPrice: localProfile.packPrice,
          packSize: localProfile.packSize,
          currencyCode: localProfile.currencyCode,
          currencySymbol: localProfile.currencySymbol,
          triggers: localProfile.triggers,
          quitReason: localProfile.quitReason,
        );
        await ref
            .read(onboardingRepositoryProvider)
            .completeOnboarding(linkedProfile);
        await ref.read(profileRepositoryProvider).upsertProfile(linkedProfile);
      }
      if (mounted) {
        context.go(
          localProfile == null ? AppRoutes.onboarding : AppRoutes.home,
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
        setState(() => _isSigningIn = false);
      }
    }
  }
}

class _PromiseCard extends StatelessWidget {
  const _PromiseCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
