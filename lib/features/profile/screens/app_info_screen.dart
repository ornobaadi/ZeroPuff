import 'package:flutter/material.dart';

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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            _InfoBlock(
              icon: Icons.medical_information_outlined,
              title: 'Medical disclaimer',
              body:
                  'ZeroPuff is a habit and tracking companion. It is not medical advice, diagnosis, or emergency care. Talk to a qualified clinician for treatment decisions, medication, or urgent health concerns.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoBlock(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy note',
              body:
                  'Your quit data is stored on this device first. If you connect Google, ZeroPuff backs up supported progress to your account so it can be restored on another device.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoBlock(
              icon: Icons.favorite_border_rounded,
              title: 'Beta promise',
              body:
                  'This beta focuses on honest logging, recovery after relapse, and small wins. No ads, social pressure, AI chat, or payment prompts are part of v0.2.',
            ),
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
