import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('App info')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.air_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppConstants.appTagline,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${AppConstants.appVersionLabel} (${AppConstants.appBuildLabel})',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900, fontVariations: AppTypography.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            _InfoBlock(
              icon: Icons.info_outline_rounded,
              title: 'Disclaimer',
              body:
                  'ZeroPuff is a habit and tracking app. It is not medical advice, diagnosis, or emergency care. Talk to a qualified professional for treatment decisions or urgent concerns.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoBlock(
              icon: Icons.calculate_outlined,
              title: 'About your stats',
              body:
                  'Cigarettes avoided and money saved are estimates based on the daily habit you told us about and how long you have been smoke-free.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoBlock(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy note',
              body:
                  'Your habit data is stored on this device first. If you connect Google, ZeroPuff backs up supported progress to your account so it can be restored on another device.',
            ),
            if (AppConstants.privacyPolicyUrl.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _LinkBlock(
                icon: Icons.policy_outlined,
                title: 'Privacy policy',
                url: AppConstants.privacyPolicyUrl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
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
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
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

class _LinkBlock extends StatelessWidget {
  const _LinkBlock({
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            const Icon(Icons.open_in_new_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
