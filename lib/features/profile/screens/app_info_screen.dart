import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('App info and safety')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    style: AppCardStyle.tonal,
                    semanticLabel:
                        '${AppConstants.appName}. ${AppConstants.appTagline} Version ${AppConstants.appVersionLabel}.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Symbols.air_rounded,
                          color: scheme.onPrimaryContainer,
                          size: 36,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppConstants.appTagline,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '${AppConstants.appVersionLabel} (${AppConstants.appBuildLabel})',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  const _InfoBlock(
                    icon: Symbols.info_rounded,
                    title: 'Disclaimer',
                    body:
                        'ZeroPuff is a habit and tracking app. It is not medical advice, diagnosis, or emergency care. Talk to a qualified professional for treatment decisions or urgent concerns.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _InfoBlock(
                    icon: Symbols.calculate_rounded,
                    title: 'About your stats',
                    body:
                        'Cigarettes not smoked and money won back are estimates based on the daily habit you told us about and how long you have been smoke-free.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _InfoBlock(
                    icon: Symbols.privacy_tip_rounded,
                    title: 'Privacy note',
                    body:
                        'Your habit data is stored on this device first. If you connect Google, ZeroPuff backs up supported progress to your account so it can be restored on another device.',
                  ),
                  if (AppConstants.privacyPolicyUrl.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      style: AppCardStyle.outlined,
                      semanticLabel: 'Privacy policy. Opens in your browser.',
                      onTap: () => launchUrl(
                        Uri.parse(AppConstants.privacyPolicyUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.policy_rounded, color: scheme.primary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Privacy policy',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Icon(Symbols.open_in_new_rounded, size: 20),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
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

    return AppCard(
      style: AppCardStyle.outlined,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
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
