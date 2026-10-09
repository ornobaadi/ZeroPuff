import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';

/// The primary action on Home: start a craving rescue. Large, always visible,
/// and labelled; the second hero moment of the screen.
class CravingButton extends StatelessWidget {
  const CravingButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.extraLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.air_rounded, size: 28),
          const SizedBox(width: AppSpacing.md),
          Text(
            "I'm craving",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The current streak, shown as a chip in the app bar.
class StreakChip extends StatelessWidget {
  const StreakChip({required this.streak, required this.onTap, super.key});

  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = AppAccents.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        button: true,
        label: 'Smoke-free streak: $streak ${streak == 1 ? 'day' : 'days'}',
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: accents.streakContainer,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.componentGap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.local_fire_department_rounded,
                      color: accents.onStreakContainer,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accents.onStreakContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
