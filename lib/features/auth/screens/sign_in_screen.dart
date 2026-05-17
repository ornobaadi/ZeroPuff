import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayMedium,
              ),
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
                icon: const Icon(Icons.login_rounded),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Google Sign-In wiring lands in Phase 3. This placeholder keeps Phase 1 and 2 navigable.',
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
}
