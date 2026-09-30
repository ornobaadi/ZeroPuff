import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_spacing.dart';

/// A large single-choice option (radio-style) with a title and supporting line.
///
/// Use several in a column for a mutually exclusive choice. Announces itself
/// to screen readers as a selectable button in an exclusive group.
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final background = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerLow;
    final foreground = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final supporting = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.short),
          curve: AppMotion.standardCurve,
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppShapes.largeIncreased,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppShapes.largeIncreased,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(icon, color: foreground),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: foreground,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: supporting,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected ? scheme.primary : scheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
