import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/ritual_preset.dart';
import '../models/onboarding_form.dart';
import '../widgets/onboarding_step_layout.dart';

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
  'stress': Symbols.bolt_rounded,
  'bored': Symbols.hourglass_empty_rounded,
  'social': Symbols.groups_rounded,
  'after food': Symbols.restaurant_rounded,
  'coffee': Symbols.local_cafe_rounded,
  'routine': Symbols.repeat_rounded,
  'other': Symbols.more_horiz_rounded,
};

class RoutineStep extends StatelessWidget {
  const RoutineStep({
    required this.form,
    required this.onChanged,
    required this.onSelection,
    super.key,
  });

  final OnboardingForm form;
  final ValueChanged<OnboardingForm> onChanged;
  final VoidCallback onSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final triggersError = form.triggersError;

    return OnboardingStepLayout(
      icon: Symbols.schedule_rounded,
      eyebrow: 'Your routine',
      title: 'When and why do cravings show up?',
      subtitle:
          'ZeroPuff uses this to nudge you before autopilot starts and to '
          'keep rescue choices fast.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which moments usually come with a cigarette?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ZeroPuff checks in a few minutes before each one. You can change the times later.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final preset in RitualPreset.all)
                FilterChip(
                  avatar: Icon(preset.icon, size: 18),
                  label: Text(preset.label),
                  selected: form.rituals.contains(preset.id),
                  onSelected: (selected) {
                    onSelection();
                    final next = {...form.rituals};
                    if (selected) {
                      next.add(preset.id);
                    } else {
                      next.remove(preset.id);
                    }
                    onChanged(form.copyWith(rituals: next));
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'What pulls you toward smoking?',
            style: theme.textTheme.titleMedium,
          ),
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
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
