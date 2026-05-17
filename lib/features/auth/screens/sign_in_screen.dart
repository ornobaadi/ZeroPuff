import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(AppConstants.appName, style: theme.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppConstants.appTagline,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.onboarding),
                icon: const Icon(Icons.explore_outlined),
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
              Text(
                'Guest data stays on this device. Sign in later to sync and protect your progress.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
            ],
          ),
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
