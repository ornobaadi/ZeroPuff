import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/home_dashboard_provider.dart';
import 'smoke_free_timer.dart';

/// The Home screen's main card: the live smoke-free clock and progress to the
/// next milestone.
class SmokeFreeHeroCard extends StatelessWidget {
  const SmokeFreeHeroCard({required this.data, required this.onTap, super.key});

  final HomeDashboardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final next = ProgressCalculations.nextMilestone(data.smokeFreeDuration);
    final shown =
        next ?? ProgressCalculations.currentMilestone(data.smokeFreeDuration);
    final previous = ProgressCalculations.previousMilestone(shown);
    final previousDuration = previous?.duration ?? Duration.zero;
    final segment = shown.duration - previousDuration;
    final elapsed = data.smokeFreeDuration - previousDuration;
    final progress = next == null || segment.inSeconds <= 0
        ? 1.0
        : (elapsed.inSeconds / segment.inSeconds).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final countdown = next == null
        ? null
        : ProgressCalculations.countdownLabel(
            next.duration - data.smokeFreeDuration,
          );

    final milestoneText = next == null
        ? 'All milestones reached'
        : 'Next milestone: ${next.title}, $countdown';
    final color = scheme.onPrimaryContainer;

    return Semantics(
      button: true,
      hint: 'Opens your smoke-free details',
      child: Material(
        color: scheme.primaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: AppShapes.extraLargeIncreased,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The same eyebrow the Today and jar cards open with.
                Row(
                  children: [
                    Icon(Symbols.eco_rounded, size: 18, color: scheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'SMOKE-FREE FOR',
                        style: AppTypography.eyebrow.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Icon(Symbols.chevron_right_rounded, color: color),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SmokeFreeTimer(since: data.smokeFreeSince),
                const SizedBox(height: AppSpacing.sm),
                // The next milestone in a box of its own, on the same grid as
                // the time tiles, counting down rather than quoting a
                // percentage.
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.55),
                    borderRadius: AppShapes.largeIncreased,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        ExcludeSemantics(
                          child: Row(
                            children: [
                              Icon(
                                Symbols.flag_rounded,
                                size: 18,
                                color: color,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  next == null
                                      ? 'All milestones reached'
                                      : next.title,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: color,
                                  ),
                                ),
                              ),
                              if (countdown != null)
                                Text(
                                  countdown,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.componentGap),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: scheme.primaryContainer,
                          color: scheme.primary,
                          semanticsLabel: milestoneText,
                          semanticsValue: '$percent',
                        ),
                      ],
                    ),
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
