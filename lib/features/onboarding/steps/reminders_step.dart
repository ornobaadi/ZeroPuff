import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/onboarding_step_layout.dart';

class RemindersStep extends StatelessWidget {
  const RemindersStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingStepLayout(
      icon: Symbols.notifications_active_rounded,
      eyebrow: 'Helpful nudges',
      title: 'Want a nudge at the right moment?',
      subtitle:
          'Cravings often arrive when motivation is quiet. Gentle reminders '
          'help you notice your progress. You choose which ones, and can '
          'change them any time in Profile.',
      child: Column(
        children: [
          _BenefitCard(
            icon: Symbols.savings_rounded,
            title: 'Progress, not spam',
            body:
                'Reminders can mention money kept, cigarettes avoided, or '
                'your current streak.',
          ),
          SizedBox(height: AppSpacing.md),
          _BenefitCard(
            icon: Symbols.fact_check_rounded,
            title: 'Skips what you already did',
            body: 'If today is already recorded, the nudge moves to tomorrow.',
          ),
          SizedBox(height: AppSpacing.md),
          _BenefitCard(
            icon: Symbols.nightlight_rounded,
            title: 'A gentle evening backup',
            body:
                'If the day is still blank, one reminder helps protect '
                'your streak.',
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
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

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.componentGap),
              child: Icon(icon, color: scheme.onSecondaryContainer),
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
