import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/serif_headline.dart';

/// The one hero moment of onboarding: the brand, the promise, and what the
/// app does. Deliberately calm and short.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Icon(
                    Symbols.air_rounded,
                    size: 72,
                    color: scheme.onPrimaryContainer,
                    semanticLabel: 'ZeroPuff',
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SerifHeadline(
              lead: 'Opening this took',
              emphasis: 'courage.',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Most people never do. You are already different. ZeroPuff '
              'helps you pause before you smoke, keep an honest record, and '
              'see your progress grow.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _ValueRow(
              icon: Symbols.timer_rounded,
              title: 'Pause when a craving hits',
              body: 'A two-minute rescue to let the urge pass.',
            ),
            const _ValueRow(
              icon: Symbols.local_fire_department_rounded,
              title: 'Watch your streak grow',
              body: 'Daily check-ins and milestones keep you going.',
            ),
            const _ValueRow(
              icon: Symbols.savings_rounded,
              title: 'See what you save',
              body: 'Cigarettes avoided and money kept, updated live.',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Setup takes about a minute. Your information stays on this '
              'device unless you choose to sign in and back it up.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
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
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.componentGap),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
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
