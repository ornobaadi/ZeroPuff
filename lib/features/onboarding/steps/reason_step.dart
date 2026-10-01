import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../models/onboarding_form.dart';
import '../widgets/onboarding_step_layout.dart';

class ReasonStep extends StatelessWidget {
  const ReasonStep({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      icon: Symbols.edit_note_rounded,
      eyebrow: 'Your reason (optional)',
      title: 'Leave yourself one honest reason',
      subtitle: 'When a craving hits, this sentence can become the pause.',
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 8,
        maxLength: OnboardingForm.maxReasonLength,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.newline,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'My reason',
          alignLabelWithHint: true,
          hintText: 'Example: I want to feel free and in control.',
        ),
      ),
    );
  }
}
