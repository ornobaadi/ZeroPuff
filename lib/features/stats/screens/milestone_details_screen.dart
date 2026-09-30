import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../progress/widgets/badge_image.dart';
import '../widgets/detail_widgets.dart';

class MilestoneDetailsScreen extends ConsumerWidget {
  const MilestoneDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);

    return DetailScaffold(
      title: 'Milestones',
      builder: (context, data) {
        final elapsed = data.smokeFreeDuration;
        final next = ProgressCalculations.nextMilestone(elapsed);
        final current = ProgressCalculations.currentMilestone(elapsed);
        final shown = next ?? current;
        final previous = ProgressCalculations.previousMilestone(shown);
        final previousDuration = previous?.duration ?? Duration.zero;
        final segmentSeconds = (shown.duration - previousDuration).inSeconds;
        final progress = next == null || segmentSeconds <= 0
            ? 1.0
            : ((elapsed - previousDuration).inSeconds / segmentSeconds).clamp(
                0.0,
                1.0,
              );

        return [
          DetailHero(
            value: ProgressCalculations.durationLabel(elapsed),
            label: 'smoke-free so far',
            icon: Icons.flag_rounded,
          ),
          _CurrentMarkerCard(
            current: current,
            next: next,
            progress: progress,
            elapsed: elapsed,
          ),
          InfoCard(
            title: next == null ? 'All milestones reached' : 'Next up',
            body: next == null
                ? 'You have reached every milestone in ZeroPuff.'
                : '${next.title}: ${next.body}',
            icon: next == null ? Icons.emoji_events_rounded : Icons.flag_rounded,
            tone: StatTone.money,
          ),
          const SectionHeader(title: 'Milestone map'),
          for (final milestone in ProgressCalculations.streakMilestones)
            _MilestoneRow(
              milestone: milestone,
              reached: elapsed >= milestone.duration,
              isCurrent: current.key == milestone.key,
              progress: ProgressCalculations.milestoneProgress(
                smokeFreeDuration: elapsed,
                milestone: milestone,
              ),
              onTap: elapsed >= milestone.duration
                  ? () {
                      HapticService.light(enabled: hapticsEnabled);
                      showBadgeDialog(
                        context,
                        asset: milestone.badgeAsset,
                        title: milestone.title,
                        body: milestone.body,
                        caption:
                            'Unlocked at ${compactDuration(milestone.duration)} smoke-free',
                        fallbackIcon: Icons.flag_rounded,
                      );
                    }
                  : null,
            ),
          const InfoCard(
            title: 'A gentle note',
            body:
                'Milestones are simple time markers to celebrate your progress. ZeroPuff does not provide medical advice.',
            icon: Icons.info_outline_rounded,
            tone: StatTone.streak,
          ),
        ];
      },
    );
  }
}

class _CurrentMarkerCard extends StatelessWidget {
  const _CurrentMarkerCard({
    required this.current,
    required this.next,
    required this.progress,
    required this.elapsed,
  });

  final ProgressMilestone current;
  final ProgressMilestone? next;
  final double progress;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reached = elapsed >= current.duration;
    final next = this.next;
    final percent = (progress * 100).round();
    final progressText = next == null
        ? '${compactDuration(elapsed)} smoke-free'
        : '$percent% to ${next.title}';

    return AppCard(
      style: AppCardStyle.tonal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BadgeImage(
                asset: current.badgeAsset,
                unlocked: reached,
                size: 88,
                fallbackIcon: Icons.flag_rounded,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reached ? 'Current marker' : 'First target',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      current.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reached
                          ? current.body
                          : 'Your first milestone arrives at 20 smoke-free minutes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            progressText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            year2023: false, // ignore: deprecated_member_use
            value: progress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: scheme.surface.withValues(alpha: 0.5),
            semanticsLabel: 'Progress to next milestone',
            semanticsValue: '$percent percent',
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.reached,
    required this.isCurrent,
    required this.progress,
    required this.onTap,
  });

  final ProgressMilestone milestone;
  final bool reached;
  final bool isCurrent;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = isCurrent
        ? 'Now'
        : reached
        ? 'Done'
        : 'Next';

    return AppCard(
      style: reached ? AppCardStyle.tonal : AppCardStyle.outlined,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel:
          '${milestone.title}, at ${compactDuration(milestone.duration)}. $status. ${milestone.body}${onTap == null ? '' : ' Double tap for the badge.'}',
      child: Row(
        children: [
          BadgeImage(
            asset: milestone.badgeAsset,
            unlocked: reached,
            size: 64,
            fallbackIcon: Icons.flag_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: reached ? scheme.onPrimaryContainer : null,
                        ),
                      ),
                    ),
                    _StatusChip(label: status, emphasized: isCurrent),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  milestone.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: reached
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  year2023: false, // ignore: deprecated_member_use
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: scheme.surface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  compactDuration(milestone.duration),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: reached
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.emphasized});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized ? scheme.primary : scheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: emphasized ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
