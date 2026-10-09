import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../rescue/widgets/breath_orb.dart';
import '../widgets/onboarding_step_layout.dart';

/// Lets the user feel the rescue once before the app asks for anything else.
class BreathStep extends StatefulWidget {
  const BreathStep({required this.hapticsEnabled, super.key});

  final bool hapticsEnabled;

  @override
  State<BreathStep> createState() => _BreathStepState();
}

class _BreathStepState extends State<BreathStep> {
  int _breaths = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return OnboardingStepLayout(
      icon: Symbols.air_rounded,
      eyebrow: 'Try it once',
      title: 'This is what helps when a craving hits',
      subtitle:
          'Press and hold the circle to breathe in. Let go to breathe out slowly.',
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: BreathOrb(
              onBreath: () => setState(() => _breaths += 1),
              hapticsEnabled: widget.hapticsEnabled,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            liveRegion: true,
            child: Text(
              _breaths == 0
                  ? 'No rush. Try one breath.'
                  : 'That is it. Six of those and most urges have passed.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _breaths == 0 ? scheme.onSurfaceVariant : scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
