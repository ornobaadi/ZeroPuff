import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_flow.dart';
import 'breath_orb.dart';

/// The first thing a craving meets: nothing to fill in, just breathing.
class RescueBreatheView extends StatelessWidget {
  const RescueBreatheView({
    required this.breathsThisRound,
    required this.hapticsEnabled,
    required this.pocketMode,
    required this.onBreath,
    required this.onPocketModeChanged,
    required this.onSkip,
    super.key,
  });

  final int breathsThisRound;
  final bool hapticsEnabled;
  final bool pocketMode;
  final VoidCallback onBreath;
  final ValueChanged<bool> onPocketModeChanged;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    if (pocketMode) {
      return _PocketMode(
        breathsThisRound: breathsThisRound,
        hapticsEnabled: hapticsEnabled,
        onBreath: onBreath,
        onExit: () => onPocketModeChanged(false),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ContentWidth(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            Semantics(
              header: true,
              child: Text(
                'Breathe with it',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No decision right now. Hold anywhere, then let go slowly.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BreathOrb(
                onBreath: onBreath,
                hapticsEnabled: hapticsEnabled,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BreathDots(done: breathsThisRound),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onPocketModeChanged(true),
                    icon: const Icon(Symbols.vibration_rounded),
                    label: const Text('Pocket mode'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Symbols.skip_next_rounded),
                    label: const Text('Skip ahead'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One dot per breath in the round.
class BreathDots extends StatelessWidget {
  const BreathDots({required this.done, this.muted = false, super.key});

  final int done;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = muted ? scheme.primary.withValues(alpha: 0.6) : scheme.primary;
    final off = muted
        ? scheme.primary.withValues(alpha: 0.18)
        : scheme.outlineVariant;

    return Semantics(
      label: 'Breath $done of ${RescueFlow.breathTarget}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < RescueFlow.breathTarget; index++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.short),
                  width: index < done ? 20 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index < done ? on : off,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A near-black screen that paces the breathing through vibration alone, for
/// when the phone is in a pocket or nobody should notice.
class _PocketMode extends StatelessWidget {
  const _PocketMode({
    required this.breathsThisRound,
    required this.hapticsEnabled,
    required this.onBreath,
    required this.onExit,
  });

  final int breathsThisRound;
  final bool hapticsEnabled;
  final VoidCallback onBreath;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const foreground = Color(0x99FFFFFF);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onExit,
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              children: [
                Text(
                  hapticsEnabled
                      ? 'Rising buzz: breathe in. Fading buzz: breathe out.'
                      : 'Haptics are off, so follow the circle instead.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: BreathOrb(
                      onBreath: onBreath,
                      hapticsEnabled: hapticsEnabled,
                      auto: true,
                      dimmed: true,
                    ),
                  ),
                ),
                BreathDots(done: breathsThisRound, muted: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tap anywhere to come back',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
