import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/selectable_tile.dart';
import '../models/onboarding_form.dart';
import '../widgets/onboarding_step_layout.dart';

class StartDateStep extends StatelessWidget {
  const StartDateStep({
    required this.form,
    required this.onChoiceSelected,
    required this.onPickDate,
    super.key,
  });

  final OnboardingForm form;
  final ValueChanged<QuitDateChoice> onChoiceSelected;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final choice = form.dateChoice;
    final error = form.quitDateError(DateTime.now());

    return OnboardingStepLayout(
      icon: Symbols.flag_rounded,
      eyebrow: 'Your start',
      title: 'When should ZeroPuff start counting?',
      subtitle: 'Pick the moment that feels honest. You can change it later.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableTile(
            title: 'Today',
            subtitle: 'Start fresh from this moment.',
            icon: Symbols.wb_sunny_rounded,
            selected: choice == QuitDateChoice.today,
            onTap: () => onChoiceSelected(QuitDateChoice.today),
          ),
          SelectableTile(
            title: 'Yesterday',
            subtitle: 'You have already begun.',
            icon: Symbols.nightlight_rounded,
            selected: choice == QuitDateChoice.yesterday,
            onTap: () => onChoiceSelected(QuitDateChoice.yesterday),
          ),
          SelectableTile(
            title: 'Choose a date',
            subtitle: choice == QuitDateChoice.custom
                ? DateFormat.yMMMEd().format(form.quitDate)
                : 'Pick an earlier day.',
            icon: Symbols.event_rounded,
            selected: choice == QuitDateChoice.custom,
            onTap: onPickDate,
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
