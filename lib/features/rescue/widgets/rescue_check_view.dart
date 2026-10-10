import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_flow.dart';
import 'rescue_reasons.dart';

/// After breathing: how strong it was, what set it off, and how it is now.
/// Only the last answer is needed to move on.
class RescueCheckView extends StatelessWidget {
  const RescueCheckView({
    required this.startStrength,
    required this.triggers,
    required this.onStartStrengthChanged,
    required this.onTriggerToggled,
    required this.onAnswer,
    required this.onSmoked,
    super.key,
  });

  final UrgeStrength startStrength;
  final Set<String> triggers;
  final ValueChanged<UrgeStrength> onStartStrengthChanged;
  final ValueChanged<String> onTriggerToggled;
  final ValueChanged<UrgeNow> onAnswer;
  final VoidCallback onSmoked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'How is the urge now?',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Be honest. Any answer is useful.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AnswerTile(
                icon: Symbols.check_circle_rounded,
                title: 'It passed',
                subtitle: 'The urge is gone or close to it.',
                background: scheme.primary,
                foreground: scheme.onPrimary,
                onTap: () => onAnswer(UrgeNow.gone),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _AnswerTile(
                icon: Symbols.trending_down_rounded,
                title: 'Weaker',
                subtitle: 'Still there, but I can ride it out.',
                background: scheme.secondaryContainer,
                foreground: scheme.onSecondaryContainer,
                onTap: () => onAnswer(UrgeNow.weaker),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _AnswerTile(
                icon: Symbols.bolt_rounded,
                title: 'Still strong',
                subtitle: 'Try something different.',
                background: accents.cravingContainer,
                foreground: accents.onCravingContainer,
                onTap: () => onAnswer(UrgeNow.stillStrong),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(
                'How strong was it at the start?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<UrgeStrength>(
                showSelectedIcon: false,
                segments: [
                  for (final strength in UrgeStrength.values)
                    ButtonSegment(value: strength, label: Text(strength.label)),
                ],
                selected: {startStrength},
                onSelectionChanged: (selection) =>
                    onStartStrengthChanged(selection.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('What set it off?', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Optional. It sharpens your patterns.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final reason in rescueReasons)
                    FilterChip(
                      avatar: Icon(reason.icon, size: 18),
                      label: Text(reason.title),
                      selected: triggers.contains(reason.value),
                      onSelected: (_) => onTriggerToggled(reason.value),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton.icon(
                  onPressed: onSmoked,
                  icon: const Icon(Symbols.edit_note_rounded),
                  label: const Text('I smoked. Log it privately.'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Shaped and sized like the app's buttons, with an arrow, so these read
    // as answers to tap rather than as cards to read.
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: background,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.button),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.componentGap,
            ),
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
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Symbols.arrow_forward_rounded, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
