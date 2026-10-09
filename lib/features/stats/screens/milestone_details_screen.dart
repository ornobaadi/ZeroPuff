import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/number_formatting.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../../progress/providers/milestone_providers.dart';
import '../../progress/widgets/badge_image.dart';
import '../../share/share_card.dart';
import '../widgets/detail_widgets.dart';

/// Upcoming time milestones shown before the rest are folded away.
const _upcomingShown = 2;

/// The icon an earned milestone uses when it has no badge art.
IconData milestoneIcon(ProgressMilestone milestone) {
  if (milestone.kind == MilestoneKind.time) {
    return Symbols.flag_rounded;
  }
  if (milestone.cravingsBeatenTarget != null) {
    return Symbols.bolt_rounded;
  }
  if (milestone.cigarettesAvoidedTarget != null) {
    return Symbols.smoke_free_rounded;
  }
  if (milestone.packsTarget != null) {
    return Symbols.savings_rounded;
  }
  if (milestone.sealedDaysTarget != null) {
    return Symbols.verified_rounded;
  }
  return Symbols.favorite_rounded;
}

/// One list of milestones: the time markers along the way, and the badges
/// earned by what the user does.
class MilestoneDetailsScreen extends ConsumerStatefulWidget {
  const MilestoneDetailsScreen({super.key});

  @override
  ConsumerState<MilestoneDetailsScreen> createState() =>
      _MilestoneDetailsScreenState();
}

class _MilestoneDetailsScreenState
    extends ConsumerState<MilestoneDetailsScreen> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final liveStats = ref.watch(milestoneStatsProvider);
    final unlocked =
        ref.watch(unlockedMilestonesProvider).value ??
        const <String, DateTime?>{};

    return DetailScaffold(
      title: 'Milestones',
      builder: (context, data) {
        final stats =
            liveStats ??
            MilestoneStats(
              smokeFreeDuration: data.smokeFreeDuration,
              cigarettesAvoided: data.cigarettesAvoided,
            );
        bool reached(ProgressMilestone milestone) {
          return unlocked.containsKey(milestone.key) ||
              milestone.isUnlocked(stats);
        }

        const time = ProgressCalculations.timeMilestones;
        final next = ProgressCalculations.nextMilestone(
          stats.smokeFreeDuration,
        );
        final upcoming = time.where((m) => !reached(m)).toList();
        final hidden = _showAll ? 0 : upcoming.length - _upcomingShown;
        final journey = [
          ...time.where(reached),
          ...upcoming.take(_showAll ? upcoming.length : _upcomingShown),
        ];
        final reachedCount = ProgressCalculations.milestones
            .where(reached)
            .length;

        return [
          _NextUpCard(
            next: next,
            stats: stats,
            reachedCount: reachedCount,
            alreadyEarned: next != null && unlocked.containsKey(next.key),
          ),
          const SectionHeader(
            title: 'Your journey',
            subtitle: 'Time smoke-free. These arrive on their own.',
          ),
          for (final milestone in journey)
            _JourneyRow(
              milestone: milestone,
              reached: reached(milestone),
              reachedAt: unlocked[milestone.key],
              isNext: milestone.key == upcoming.firstOrNull?.key,
              stats: stats,
              onTap: reached(milestone)
                  ? () => _showBadge(milestone, data, unlocked[milestone.key])
                  : null,
            ),
          if (hidden > 0)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showAll = true),
                icon: const Icon(Symbols.expand_more_rounded),
                label: Text('$hidden more further ahead'),
              ),
            ),
          const SectionHeader(
            title: 'Earned',
            subtitle: 'For what you do, not how long you wait.',
          ),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final milestone in ProgressCalculations.earnedMilestones)
                  _EarnedTile(
                    width: _tileWidth(constraints.maxWidth),
                    milestone: milestone,
                    unlocked: reached(milestone),
                    stats: stats,
                    onTap: reached(milestone)
                        ? () => _showBadge(
                            milestone,
                            data,
                            unlocked[milestone.key],
                          )
                        : null,
                  ),
              ],
            ),
          ),
          const InfoCard(
            title: 'A gentle note',
            body:
                'Milestones mark time and effort so progress is easy to see. ZeroPuff does not provide medical advice.',
            icon: Symbols.info_rounded,
            tone: StatTone.streak,
          ),
        ];
      },
    );
  }

  void _showBadge(
    ProgressMilestone milestone,
    HomeDashboardData data,
    DateTime? reachedAt,
  ) {
    HapticService.light(enabled: ref.read(hapticsEnabledControllerProvider));
    final isTime = milestone.kind == MilestoneKind.time;
    showBadgeDialog(
      context,
      asset: milestone.badgeAsset,
      title: isTime ? (milestone.name ?? milestone.title) : milestone.title,
      body: milestone.body,
      caption: reachedAt == null
          ? (isTime ? '${milestone.title} smoke-free' : null)
          : '${isTime ? '${milestone.title} smoke-free' : 'Earned'} · ${DateFormat.yMMMd().format(reachedAt)}',
      fallbackIcon: milestoneIcon(milestone),
      share: ShareCardData(
        headline: milestone.title,
        caption: isTime ? 'smoke-free' : 'earned',
        lines: [
          if (!isTime) milestone.body,
          if (isTime && data.cigarettesAvoided > 0)
            '${formatCount(data.cigarettesAvoided)} cigarettes not smoked',
          if (isTime && data.moneySaved >= 1)
            '${formatMoney(data.currencySymbol, data.moneySaved)} kept',
        ],
      ),
    );
  }
}

/// Two columns on phones, three when there is room.
double _tileWidth(double available) {
  final columns = available >= 520 ? 3 : 2;
  return (available - AppSpacing.sm * (columns - 1)) / columns;
}

/// The next time milestone and how far off it is.
class _NextUpCard extends StatelessWidget {
  const _NextUpCard({
    required this.next,
    required this.stats,
    required this.reachedCount,
    required this.alreadyEarned,
  });

  final ProgressMilestone? next;
  final MilestoneStats stats;
  final int reachedCount;

  /// The clock restarted after a slip, and this one was reached before.
  final bool alreadyEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.onPrimaryContainer;
    final next = this.next;
    final total = ProgressCalculations.milestones.length;

    if (next == null) {
      return AppCard(
        style: AppCardStyle.tonal,
        child: Text(
          'Every time milestone reached. $reachedCount of $total milestones in all.',
          style: theme.textTheme.titleMedium?.copyWith(color: color),
        ),
      );
    }

    final previous = ProgressCalculations.previousMilestone(next);
    final from = previous?.duration ?? Duration.zero;
    final span = (next.duration - from).inSeconds;
    final progress = span <= 0
        ? 1.0
        : ((stats.smokeFreeDuration - from).inSeconds / span).clamp(0.0, 1.0);
    final until = next.progressLabel(stats) ?? '';

    return AppCard(
      style: AppCardStyle.tonal,
      semanticLabel:
          'Next milestone: ${next.title} smoke-free, $until. '
          '$reachedCount of $total milestones reached.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BadgeImage(
                asset: next.badgeAsset,
                unlocked: alreadyEarned,
                size: 80,
                fallbackIcon: Symbols.flag_rounded,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alreadyEarned ? 'On the way back to' : 'Next up',
                      style: theme.textTheme.labelLarge?.copyWith(color: color),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      next.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: color,
                      ),
                    ),
                    Text(
                      until,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: scheme.surface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$reachedCount of $total milestones reached',
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// One time milestone on the journey.
class _JourneyRow extends StatelessWidget {
  const _JourneyRow({
    required this.milestone,
    required this.reached,
    required this.reachedAt,
    required this.isNext,
    required this.stats,
    required this.onTap,
  });

  final ProgressMilestone milestone;
  final bool reached;
  final DateTime? reachedAt;
  final bool isNext;
  final MilestoneStats stats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = reached ? scheme.onPrimaryContainer : scheme.onSurface;
    final muted = reached ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    final at = reachedAt;
    final status = reached
        ? (at == null ? 'Reached' : 'Reached ${DateFormat.MMMd().format(at)}')
        : (milestone.progressLabel(stats) ?? '');
    final name = milestone.name;

    return AppCard(
      style: reached ? AppCardStyle.tonal : AppCardStyle.outlined,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel:
          '${milestone.title} smoke-free${name == null ? '' : ', $name'}. '
          '$status.${onTap == null ? '' : ' Double tap for the badge.'}',
      child: Row(
        children: [
          BadgeImage(
            asset: milestone.badgeAsset,
            unlocked: reached,
            size: 56,
            fallbackIcon: Symbols.flag_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: theme.textTheme.titleMedium?.copyWith(color: onCard),
                ),
                if (name != null)
                  Text(
                    name,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                if (isNext) ...[
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: milestone.progress(stats),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            status,
            style: theme.textTheme.labelMedium?.copyWith(
              color: reached || isNext ? scheme.primary : muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A badge earned by doing something, with how far along it is.
class _EarnedTile extends StatelessWidget {
  const _EarnedTile({
    required this.width,
    required this.milestone,
    required this.unlocked,
    required this.stats,
    required this.onTap,
  });

  final double width;
  final ProgressMilestone milestone;
  final bool unlocked;
  final MilestoneStats stats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final color = unlocked
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final label = unlocked ? 'Earned' : milestone.progressLabel(stats);

    return SizedBox(
      width: width,
      child: AppCard(
        style: unlocked ? AppCardStyle.tonal : AppCardStyle.outlined,
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        semanticLabel:
            '${milestone.title}. ${milestone.body} '
            '${unlocked ? 'Earned.' : (label == null ? 'Not earned yet.' : '$label.')}',
        child: Column(
          children: [
            BadgeImage(
              asset: milestone.badgeAsset,
              unlocked: unlocked,
              size: 72,
              fallbackIcon: milestoneIcon(milestone),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              milestone.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
            if (!unlocked) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: milestone.progress(stats),
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
                color: accents.money,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ],
            if (label != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: unlocked ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
