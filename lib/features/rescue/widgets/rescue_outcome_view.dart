import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_phase.dart';

/// After the two minutes: how strong is the urge now, and what happened.
class RescueOutcomeView extends StatelessWidget {
  const RescueOutcomeView({
    required this.completedPhaseIds,
    required this.urgeAfter,
    required this.onUrgeChanged,
    required this.onOutcome,
    super.key,
  });

  final Set<String> completedPhaseIds;
  final int urgeAfter;
  final ValueChanged<int> onUrgeChanged;
  final ValueChanged<String> onOutcome;

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
                  'Check the urge now',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No shame. Honest data is how the app gets useful.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _CompletedPhaseRow(completedPhaseIds: completedPhaseIds),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Where is the urge?',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '$urgeAfter/10',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    Slider(
                      value: urgeAfter.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: urgeAfter.toString(),
                      semanticFormatterCallback: (value) =>
                          'Urge intensity ${value.round()} out of 10',
                      onChanged: (value) => onUrgeChanged(value.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('What happened?', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.componentGap),
              _OutcomeTile(
                icon: Symbols.check_circle_rounded,
                title: 'I resisted',
                subtitle: 'Save the win and return home.',
                background: scheme.primaryContainer,
                foreground: scheme.onPrimaryContainer,
                onTap: () => onOutcome('resisted'),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _OutcomeTile(
                icon: Symbols.refresh_rounded,
                title: 'Still craving',
                subtitle: 'Log this round and start another immediately.',
                background: accents.cravingContainer,
                foreground: accents.onCravingContainer,
                onTap: () => onOutcome('still_craving'),
              ),
              const SizedBox(height: AppSpacing.componentGap),
              _OutcomeTile(
                icon: Symbols.edit_note_rounded,
                title: 'I smoked',
                subtitle: 'Log it privately. You did not lose everything.',
                background: scheme.surfaceContainerHigh,
                foreground: scheme.onSurface,
                onTap: () => onOutcome('smoked'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompletedPhaseRow extends StatelessWidget {
  const _CompletedPhaseRow({required this.completedPhaseIds});

  final Set<String> completedPhaseIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = completedPhaseIds.length;

    return Semantics(
      label: '$done of ${rescuePhases.length} steps completed',
      child: ExcludeSemantics(
        child: AppCard(
          style: AppCardStyle.outlined,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              for (final phase in rescuePhases)
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        completedPhaseIds.contains(phase.id)
                            ? Symbols.check_circle_rounded
                            : phase.icon,
                        color: completedPhaseIds.contains(phase.id)
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        phase.title.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutcomeTile extends StatelessWidget {
  const _OutcomeTile({
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

    return AppCard(
      color: background,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
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
                  style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
