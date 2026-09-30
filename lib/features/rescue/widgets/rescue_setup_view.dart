import 'package:flutter/material.dart';

import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_phase.dart';
import 'rescue_reasons.dart';

/// Step 1 of a rescue: how strong is the urge, and what is behind it.
class RescueSetupView extends StatelessWidget {
  const RescueSetupView({
    required this.intensity,
    required this.triggers,
    required this.onIntensityChanged,
    required this.onTriggerToggled,
    required this.onStart,
    super.key,
  });

  final int intensity;
  final Set<String> triggers;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<String> onTriggerToggled;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: scheme.primaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppShapes.extraLargeIncreased,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.air_rounded,
                              size: 40,
                              color: scheme.onPrimaryContainer,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Semantics(
                              header: true,
                              child: Text(
                                'Let us lower the urge first.',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              intensity >= 8
                                  ? 'This one feels strong, so the steps will stay concrete.'
                                  : 'Name what is pulling you, then follow one small step at a time.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const _PhasePreviewRow(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Intensity',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '$intensity/10',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          Slider(
                            value: intensity.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: intensity.toString(),
                            semanticFormatterCallback: (value) =>
                                'Urge intensity ${value.round()} out of 10',
                            onChanged: onIntensityChanged,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mild',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Very strong',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    Text(
                      'What is pulling you right now?',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Optional. Pick anything that fits to make the next two minutes more specific.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                  ],
                ),
              ),
            ],
          ),
        ),
        Material(
          color: scheme.surface,
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.sm,
                AppSpacing.pagePadding,
                AppSpacing.md,
              ),
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Start two minutes'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhasePreviewRow extends StatelessWidget {
  const _PhasePreviewRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        for (final phase in rescuePhases)
          Expanded(
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.componentGap),
                    child: Icon(
                      phase.icon,
                      size: 20,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  phase.title.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
