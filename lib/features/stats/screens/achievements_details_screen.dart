import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../progress/screens/progress_screen.dart';
import '../../progress/widgets/badge_image.dart';
import '../widgets/detail_widgets.dart';

class AchievementsDetailsScreen extends ConsumerWidget {
  const AchievementsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const {};
    final hapticsEnabled = ref.watch(hapticsEnabledControllerProvider);
    final achievements = ProgressCalculations.achievements;
    final unlockedCount = achievements
        .where((achievement) => unlocked.contains(achievement.key))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlockedCount of ${achievements.length} unlocked',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap an unlocked badge to see its story.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final achievement in achievements)
                          _AchievementTile(
                            width: _tileWidth(constraints.maxWidth),
                            achievement: achievement,
                            unlocked: unlocked.contains(achievement.key),
                            onTap: () {
                              HapticService.light(enabled: hapticsEnabled);
                              showBadgeDialog(
                                context,
                                asset: achievement.badgeAsset,
                                title: achievement.title,
                                body: achievement.body,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two columns on phones, three when there is room.
double _tileWidth(double available) {
  final columns = available >= 520 ? 3 : 2;
  return (available - AppSpacing.sm * (columns - 1)) / columns;
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.width,
    required this.achievement,
    required this.unlocked,
    required this.onTap,
  });

  final double width;
  final ProgressMilestone achievement;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: AppCard(
        style: unlocked ? AppCardStyle.tonal : AppCardStyle.outlined,
        onTap: unlocked ? onTap : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        semanticLabel:
            '${achievement.title}. ${unlocked ? 'Unlocked' : 'Locked'}. ${achievement.body}',
        child: Column(
          children: [
            BadgeImage(
              asset: achievement.badgeAsset,
              unlocked: unlocked,
              size: 96,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: unlocked
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              achievement.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: unlocked
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
            if (!unlocked) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Locked',
                style: theme.textTheme.labelSmall?.copyWith(
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
