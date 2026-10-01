import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
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

    final milestoneText = next == null
        ? 'All milestones reached'
        : 'Next milestone: ${next.title}';

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'You are smoke-free for',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SmokeFreeTimer(since: data.smokeFreeSince),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestoneText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: scheme.surface.withValues(alpha: 0.55),
                  color: scheme.primary,
                  semanticsLabel: milestoneText,
                  semanticsValue: '$percent',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
