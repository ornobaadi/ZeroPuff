import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/detail_widgets.dart';

class StreakDetailsScreen extends ConsumerWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DetailScaffold(
      title: 'Smoke-free streak',
      gap: AppSpacing.lg,
      builder: (context, data) {
        final streak = data.smokeFreeStreakDays;
        return [
          _StreakHero(streak: streak),
          Text(
            _headline(streak),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            'One day at a time. The only streak that matters here is the clean-air chain you are building.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const InfoCard(
            title: 'How this streak works',
            body:
                'It counts smoke-free check-ins in a row. Missing a day breaks the streak; logging a smoke resets the clock.',
            icon: Icons.air_rounded,
          ),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.checkIn),
            icon: const Icon(Icons.check_rounded),
            label: Text(
              data.todayCheckIn == null ? 'Check in today' : 'Review today',
            ),
          ),
        ];
      },
    );
  }

  String _headline(int streak) {
    if (streak == 0) {
      return 'Ready to start the first day.';
    }
    if (streak == 1) {
      return 'That first day is real.';
    }
    return '$streak days in a row. Keep going.';
  }
}

/// The single hero moment on this screen: a calm streak badge.
class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accents = AppAccents.of(context);
    final label = streak == 1 ? 'day' : 'days';

    return Semantics(
      label: 'Smoke-free streak: $streak $label',
      excludeSemantics: true,
      child: Center(
        child: AppCard(
          color: accents.streakContainer,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 44,
                color: accents.onStreakContainer,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$streak',
                style: AppTypography.displayNumber.copyWith(
                  color: accents.onStreakContainer,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accents.onStreakContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
