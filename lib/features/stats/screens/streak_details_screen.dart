import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';

class StreakDetailsScreen extends ConsumerWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboard = ref.watch(homeDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Smoke-free streak')),
      body: SafeArea(
        child: dashboard.when(
          data: (data) => LayoutBuilder(
            builder: (context, constraints) {
              final heroSize = (constraints.maxHeight * 0.36).clamp(
                220.0,
                320.0,
              );
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.sm,
                  AppSpacing.pagePadding,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: heroSize,
                      width: heroSize,
                      child: _StreakHero(streak: data.smokeFreeStreakDays),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _headline(data.smokeFreeStreakDays),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'One day at a time. The only streak that matters here is the clean-air chain you are building.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _SoftInfoCard(
                      icon: Icons.air_rounded,
                      title: 'How this streak works',
                      body:
                          'It tracks consecutive smoke-free days. Logging a smoke resets the streak.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.checkIn),
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          data.todayCheckIn == null
                              ? 'Check in today'
                              : 'Review today',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              Text('Streak unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }

  String _headline(int streak) {
    if (streak == 0) {
      return 'Ready to light the first day.';
    }
    if (streak == 1) {
      return 'That first day is real.';
    }
    return '$streak days in a row. Keep breathing.';
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _GlowRing(
            sizeFactor: 0.94,
            color: AppColors.accentStreak.withValues(
              alpha: isDark ? 0.08 : 0.1,
            ),
          ),
          _GlowRing(
            sizeFactor: 0.72,
            color: AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.14),
          ),
          _GlowRing(
            sizeFactor: 0.50,
            color: AppColors.accentMoney.withValues(
              alpha: isDark ? 0.10 : 0.16,
            ),
          ),
          Container(
            width: 178,
            height: 178,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentStreak.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 42,
                  color: AppColors.accentStreak,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$streak',
                  style: AppTypography.displayNumber.copyWith(
                    fontSize: 70,
                    height: 0.9,
                    color: isDark ? AppColors.cream : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  streak == 1 ? 'day' : 'days',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 34,
            right: 58,
            child: _Sparkle(size: 12, color: AppColors.accentMoney),
          ),
          const Positioned(
            left: 54,
            bottom: 78,
            child: _Sparkle(size: 9, color: AppColors.primary),
          ),
          const Positioned(
            bottom: 30,
            right: 92,
            child: _Sparkle(size: 7, color: AppColors.accentStreak),
          ),
        ],
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.sizeFactor, required this.color});

  final double sizeFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: sizeFactor,
      heightFactor: sizeFactor,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SoftInfoCard extends StatelessWidget {
  const _SoftInfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
