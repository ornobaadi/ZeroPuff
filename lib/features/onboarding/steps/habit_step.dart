import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/number_stepper.dart';
import '../models/onboarding_form.dart';
import '../widgets/onboarding_step_layout.dart';

class HabitStep extends StatelessWidget {
  const HabitStep({
    required this.form,
    required this.onChanged,
    required this.onSelection,
    super.key,
  });

  final OnboardingForm form;
  final ValueChanged<OnboardingForm> onChanged;

  /// Called for a light haptic when a choice changes.
  final VoidCallback onSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepLayout(
      icon: Symbols.tune_rounded,
      eyebrow: 'Your habit',
      title: 'Make your progress measurable',
      subtitle:
          'No judgement here. These numbers turn time into real feedback, '
          'and you can edit them any time.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Currency', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final currency in CurrencyOption.all)
                ChoiceChip(
                  label: Text('${currency.symbol} ${currency.code}'),
                  selected: form.currency.code == currency.code,
                  tooltip: currency.name,
                  onSelected: (_) {
                    onSelection();
                    onChanged(form.copyWith(currency: currency));
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          NumberStepper(
            label: 'Cigarettes per day',
            value: form.cigarettesPerDay,
            min: 0,
            max: 80,
            errorText: form.cigarettesError,
            onChanged: (value) {
              onSelection();
              onChanged(form.copyWith(cigarettesPerDay: value));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          NumberStepper(
            label: 'Pack price',
            value: form.packPrice,
            min: 0,
            max: 10000,
            prefix: form.currency.symbol,
            step: form.currency.largePriceStep ? 10 : 1,
            errorText: form.packPriceError,
            onChanged: (value) {
              onSelection();
              onChanged(form.copyWith(packPrice: value));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          NumberStepper(
            label: 'Cigarettes per pack',
            value: form.packSize,
            min: 0,
            max: 60,
            errorText: form.packSizeError,
            onChanged: (value) {
              onSelection();
              onChanged(form.copyWith(packSize: value));
            },
          ),
        ],
      ),
    );
  }
}
