import 'package:flutter/material.dart';

import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/smoking_window_data.dart';

/// Lets the user set the part of the day when cravings usually show up, with
/// exact time pickers and a range slider (30-minute steps).
class SmokingWindowCard extends StatelessWidget {
  const SmokingWindowCard({
    required this.startMinutes,
    required this.endMinutes,
    required this.onRangeChanged,
    required this.onPickStart,
    required this.onPickEnd,
    this.errorText,
    super.key,
  });

  final int startMinutes;
  final int endMinutes;
  final void Function(int startMinutes, int endMinutes) onRangeChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final start = startMinutes.clamp(0, 24 * 60);
    final end = endMinutes.clamp(0, 24 * 60);
    final startLabel = SmokingWindowData.labelForMinutes(start);
    final endLabel = SmokingWindowData.labelForMinutes(end);
    final hasError = errorText != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppShapes.largeIncreased,
        border: Border.all(
          color: hasError ? scheme.error : scheme.outlineVariant,
          width: hasError ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usual smoke window', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'When do cravings usually show up?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Starts',
                    value: startLabel,
                    onTap: onPickStart,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimeButton(
                    label: 'Ends',
                    value: endLabel,
                    onTap: onPickEnd,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(start.toDouble(), end.toDouble()),
              min: 0,
              max: 24 * 60,
              divisions: 48,
              labels: RangeLabels(startLabel, endLabel),
              semanticFormatterCallback: (value) =>
                  SmokingWindowData.labelForMinutes(value.round()),
              onChanged: (next) =>
                  onRangeChanged(next.start.round(), next.end.round()),
            ),
            if (hasError)
              Text(
                errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: '$label at $value. Double tap to change.',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: scheme.secondaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.large),
        child: InkWell(
          borderRadius: AppShapes.large,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
