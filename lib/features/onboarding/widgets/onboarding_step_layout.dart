import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/serif_headline.dart';

/// Shared layout for an onboarding step: an icon and eyebrow, a headline, an
/// optional supporting line, then the step's content. Scrolls when the content
/// (or the user's text size) does not fit.
class OnboardingStepLayout extends StatelessWidget {
  const OnboardingStepLayout({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.subtitle,
    this.emphasis,
    super.key,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String? subtitle;

  /// Optional italic, sage-colored second line of the headline.
  final String? emphasis;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.componentGap),
                    child: Icon(
                      icon,
                      size: 20,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: AppTypography.eyebrow.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SerifHeadline(
              lead: title,
              emphasis: emphasis,
              style: theme.textTheme.headlineLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}
