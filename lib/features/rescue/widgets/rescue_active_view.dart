import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_phase.dart';
import 'rescue_visuals.dart';

const double _minContentHeight = 620;

/// The guided two minutes: a countdown, a step timeline, the current task, and
/// one clear action. Scrolls on short screens instead of overflowing.
class RescueActiveView extends StatelessWidget {
  const RescueActiveView({
    required this.intensity,
    required this.progress,
    required this.quitReason,
    required this.onCompletePhase,
    super.key,
  });

  final int intensity;
  final RescueProgressState progress;
  final String quitReason;
  final VoidCallback onCompletePhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final phase = progress.currentPhase;
    final phaseNumber = rescuePhases.indexOf(phase) + 1;
    final minutes = progress.remainingSeconds ~/ 60;
    final seconds = progress.remainingSeconds.remainder(60);
    final isCompleted = progress.completedPhaseIds.contains(phase.id);
    final requiresConfirmation = phase.requiresConfirmation(intensity);
    final showPrimaryAction =
        progress.waitingForConfirmation ||
        (requiresConfirmation && !isCompleted);

    // Fill the screen when there is room; scroll instead of overflowing on
    // short screens (landscape phones, large text).
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: SizedBox(
          height: box.maxHeight < _minContentHeight
              ? _minContentHeight
              : box.maxHeight,
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                progress.waitingForConfirmation
                                    ? 'Finish this step'
                                    : 'Stay with this minute',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Step $phaseNumber of ${rescuePhases.length}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        label:
                            'Time left: $minutes ${minutes == 1 ? 'minute' : 'minutes'} '
                            'and $seconds ${seconds == 1 ? 'second' : 'seconds'}',
                        child: ExcludeSemantics(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: AppShapes.largeIncreased,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Text(
                                '$minutes:${seconds.toString().padLeft(2, '0')}',
                                style: AppTypography.liveCounter.copyWith(
                                  fontSize: 36,
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PhaseTimeline(progress: progress),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.standard),
                      child: _PhaseTaskCard(
                        key: ValueKey(phase.id),
                        phase: phase,
                        progress: progress,
                        quitReason: quitReason,
                        phaseNumber: phaseNumber,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (showPrimaryAction)
                    FilledButton.icon(
                      onPressed: onCompletePhase,
                      icon: Icon(
                        progress.waitingForConfirmation
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_rounded,
                      ),
                      label: Text(phase.completeLabel),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: isCompleted ? null : onCompletePhase,
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.check_rounded,
                      ),
                      label: Text(
                        isCompleted ? 'Step noted' : phase.completeLabel,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(
                      'No decision right now. Just finish this window.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
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

class _PhaseTimeline extends StatelessWidget {
  const _PhaseTimeline({required this.progress});

  final RescueProgressState progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Step ${progress.phaseIndex + 1} of ${rescuePhases.length}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var index = 0; index < rescuePhases.length; index++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == rescuePhases.length - 1
                        ? 0
                        : AppSpacing.sm,
                  ),
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.short),
                    height: index == progress.phaseIndex ? 10 : 6,
                    decoration: BoxDecoration(
                      color:
                          index <= progress.phaseIndex ||
                              progress.completedPhaseIds.contains(
                                rescuePhases[index].id,
                              )
                          ? scheme.primary
                          : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhaseTaskCard extends StatelessWidget {
  const _PhaseTaskCard({
    required this.phase,
    required this.progress,
    required this.quitReason,
    required this.phaseNumber,
    super.key,
  });

  final RescuePhase phase;
  final RescueProgressState progress;
  final String quitReason;
  final int phaseNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppShapes.extraLarge,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.componentGap),
                    child: Icon(phase.icon, color: scheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        liveRegion: true,
                        child: Text(
                          phase.title,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        progress.waitingForConfirmation
                            ? 'Ready for your tap'
                            : '${progress.phaseRemainingSeconds}s in this step',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: AppShapes.largeIncreased,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: switch (phase.id) {
                      'water' => WaterVisual(progress: progress.phaseProgress),
                      'breathing' => const BreathingVisual(),
                      'walk' => WalkVisual(progress: progress.phaseProgress),
                      _ => ReasonVisual(reason: quitReason),
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: AppShapes.large,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.radio_button_checked_rounded,
                      color: scheme.onSecondaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        phase.id == 'reason' ? quitReason : phase.instruction,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (progress.waitingForConfirmation) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Confirm this one before we move on.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
