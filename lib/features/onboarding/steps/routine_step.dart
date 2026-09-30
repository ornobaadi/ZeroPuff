import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/onboarding_form.dart';
import '../widgets/onboarding_step_layout.dart';
import '../widgets/smoking_window_card.dart';

const kTriggerOptions = [
  TriggerOption('stress', 'Stressed'),
  TriggerOption('bored', 'Bored'),
  TriggerOption('social', 'Social pressure'),
  TriggerOption('after food', 'After food'),
  TriggerOption('coffee', 'Coffee'),
  TriggerOption('routine', 'Routine'),
  TriggerOption('other', 'Something else'),
];

const _triggerIcons = <String, IconData>{
  'stress': Icons.bolt_rounded,
  'bored': Icons.hourglass_empty_rounded,
  'social': Icons.groups_rounded,
  'after food': Icons.restaurant_rounded,
  'coffee': Icons.local_cafe_rounded,
  'routine': Icons.repeat_rounded,
  'other': Icons.more_horiz_rounded,
};

class RoutineStep extends StatelessWidget {
  const RoutineStep({
    required this.form,
    required this.onChanged,
    required this.onSelection,
    required this.onPickStart,
    required this.onPickEnd,
    super.key,
  });

  final OnboardingForm form;
  final ValueChanged<OnboardingForm> onChanged;
  final VoidCallback onSelection;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final triggersError = form.triggersError;

    return OnboardingStepLayout(
      icon: Icons.schedule_rounded,
      eyebrow: 'Your routine',
      title: 'When and why do cravings show up?',
      subtitle:
          'ZeroPuff uses this to nudge you before autopilot starts and to '
          'keep rescue choices fast.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmokingWindowCard(
            startMinutes: form.smokeWindowStartMinutes,
            endMinutes: form.smokeWindowEndMinutes,
            errorText: form.windowError,
            onRangeChanged: (start, end) {
              onSelection();
              onChanged(
                form.copyWith(
                  smokeWindowStartMinutes: start,
                  smokeWindowEndMinutes: end,
                ),
              );
            },
            onPickStart: onPickStart,
            onPickEnd: onPickEnd,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('What pulls you toward smoking?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick all that apply.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final option in kTriggerOptions)
                FilterChip(
                  avatar: Icon(_triggerIcons[option.value], size: 18),
                  label: Text(option.label),
                  selected: form.triggers.contains(option.value),
                  onSelected: (selected) {
                    onSelection();
                    final next = {...form.triggers};
                    if (selected) {
                      next.add(option.value);
                    } else {
                      next.remove(option.value);
                    }
                    onChanged(form.copyWith(triggers: next));
                  },
                ),
            ],
          ),
          if (triggersError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                triggersError,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
