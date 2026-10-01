import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

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

/// Today's check-in: a prompt until it is done, then a quiet confirmation.
class CheckInCard extends StatelessWidget {
  const CheckInCard({
    required this.checkedIn,
    required this.smokeFreeToday,
    required this.onTap,
    super.key,
  });

  final bool checkedIn;
  final bool? smokeFreeToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final title = checkedIn ? 'Check-in complete' : 'Daily check-in';
    final body = checkedIn
        ? (smokeFreeToday == true
              ? 'Today is marked smoke-free.'
              : 'Today is logged honestly. That still counts.')
        : 'Take one minute to log how today is going.';

    return AppCard(
      style: checkedIn ? AppCardStyle.tonal : AppCardStyle.outlined,
      color: checkedIn ? scheme.secondaryContainer : null,
      onTap: onTap,
      semanticLabel: '$title. $body',
      child: Row(
        children: [
          Icon(
            checkedIn ? Symbols.check_circle_rounded : Symbols.today_rounded,
            color: checkedIn
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: checkedIn ? scheme.onSecondaryContainer : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: checkedIn
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Symbols.chevron_right_rounded,
            color: checkedIn
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// A low-emphasis shortcut to record a cigarette.
class QuickLogCard extends StatelessWidget {
  const QuickLogCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      style: AppCardStyle.outlined,
      onTap: onTap,
      semanticLabel: 'Need to log? Private, quick, and shame-free.',
      child: Row(
        children: [
          Icon(Symbols.edit_note_rounded, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need to log?', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Private, quick, and shame-free.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Symbols.chevron_right_rounded, color: scheme.onSurfaceVariant),
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
