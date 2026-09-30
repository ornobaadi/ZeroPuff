import 'package:flutter/material.dart';

import '../theme/app_accents.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

/// Which semantic color a [StatCard] uses.
enum StatTone { primary, money, streak, craving }

/// A compact metric: icon, big value, and a label. Tappable when [onTap] is set.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.suffix,
    this.tone = StatTone.primary,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final StatTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);

    final (container, onContainer) = switch (tone) {
      StatTone.primary => (scheme.primaryContainer, scheme.onPrimaryContainer),
      StatTone.money => (accents.moneyContainer, accents.onMoneyContainer),
      StatTone.streak => (accents.streakContainer, accents.onStreakContainer),
      StatTone.craving => (
        accents.cravingContainer,
        accents.onCravingContainer,
      ),
    };

    final spoken = suffix == null ? '$label: $value' : '$label: $value $suffix';

    return AppCard(
      onTap: onTap,
      semanticLabel: spoken,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: container,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(icon, color: onContainer, size: 24),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (suffix != null)
            Text(
              suffix!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
