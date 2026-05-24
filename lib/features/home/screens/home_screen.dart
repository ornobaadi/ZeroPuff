import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../celebrations/milestone_celebration_controller.dart';
import '../../celebrations/widgets/celebration_dialog.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/notifications/notification_service.dart';
import '../providers/home_dashboard_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _shownCelebrationKey;

  @override
  void initState() {
    super.initState();
    ref.listenManual(milestoneCelebrationProvider, (previous, next) {
      final event = next.value;
      if (event == null || event.key == _shownCelebrationKey) {
        return;
      }
      _shownCelebrationKey = event.key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCelebrationDialog(event);
          if (event.kind == CelebrationKind.healthMilestone) {
            _rescheduleMilestoneNotifications();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboard = ref.watch(homeDashboardProvider);
    ref.watch(milestoneCelebrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroPuff'),
        actions: [
          dashboard.maybeWhen(
            data: (data) => _AppBarStreak(
              streak: data.smokeFreeStreakDays,
              onTap: () => context.push(AppRoutes.streakDetails),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Log cigarette',
            onPressed: () => context.push(AppRoutes.logging),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            120,
          ),
          children: dashboard.when(
            data: (data) => [
              _SmokeFreeHero(
                data: data,
                onTap: () => context.push(AppRoutes.smokeFreeDetails),
              ),
              const SizedBox(height: AppSpacing.md),
              _TodayCard(
                checkedIn: data.todayCheckIn != null,
                smokeFreeToday: data.todayCheckIn?.smokeFreeToday,
                onTap: () => context.push(AppRoutes.checkIn),
              ),
              const SizedBox(height: AppSpacing.lg),
              _BreathingCravingButton(
                onPressed: () => context.push(AppRoutes.rescue),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Not smoked',
                      value: '${data.cigarettesAvoided}',
                      suffix: 'cigarettes',
                      color: AppColors.primary,
                      icon: Icons.smoke_free_rounded,
                      onTap: () => context.push(AppRoutes.avoidedDetails),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricCard(
                      label: 'Saved',
                      value:
                          '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
                      suffix: 'estimated',
                      color: AppColors.accentMoney,
                      icon: Icons.savings_rounded,
                      onTap: () => context.push(AppRoutes.savingsDetails),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickLogCard(onTap: () => context.push(AppRoutes.logging)),
            ],
            loading: () => [
              const SizedBox(height: 160),
              const Center(child: CircularProgressIndicator()),
            ],
            error: (error, _) => [
              Text(
                'Could not load dashboard',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCelebrationDialog(CelebrationEvent event) async {
    await showDialog<void>(
      context: context,
      builder: (context) => CelebrationDialog(event: event),
    );
  }

  Future<void> _rescheduleMilestoneNotifications() async {
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile?.quitDate,
    );
  }
}

class _SmokeFreeHero extends StatelessWidget {
  const _SmokeFreeHero({required this.data, required this.onTap});

  final HomeDashboardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nextMilestone = ProgressCalculations.nextMilestone(
      data.smokeFreeDuration,
    );
    final shownMilestone =
        nextMilestone ??
        ProgressCalculations.currentMilestone(data.smokeFreeDuration);
    final previousMilestone = ProgressCalculations.previousMilestone(
      shownMilestone,
    );
    final previousDuration = previousMilestone?.duration ?? Duration.zero;
    final segmentDuration = shownMilestone.duration - previousDuration;
    final segmentElapsed = data.smokeFreeDuration - previousDuration;
    final milestoneProgress = nextMilestone == null
        ? 1.0
        : (segmentElapsed.inSeconds / segmentDuration.inSeconds).clamp(
            0.0,
            1.0,
          );
    final milestonePercent = (milestoneProgress * 100).round().clamp(0, 100);

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.air_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Smoke-free clock',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You are smoke-free for',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _FlipTimer(data: data),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text(
                  nextMilestone == null
                      ? '${shownMilestone.title} milestone'
                      : '${shownMilestone.title} milestone',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '$milestonePercent%',
                  style: AppTypography.displayNumber.copyWith(
                    fontSize: 18,
                    color: AppColors.accentMoney,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: milestoneProgress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: AppColors.accentMoney,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipTimer extends StatelessWidget {
  const _FlipTimer({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.14)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : AppColors.navBlue.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    data.smokeFreeDays.toString(),
                    style: AppTypography.displayNumber.copyWith(
                      fontSize: 76,
                      height: 0.92,
                      color: isDark ? AppColors.cream : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  data.smokeFreeDays == 1 ? 'day' : 'days',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TimePill(value: data.smokeFreeHours, label: 'hour'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TimePill(value: data.smokeFreeMinutes, label: 'min'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TimePill(
                  value: data.smokeFreeSeconds,
                  label: 'sec',
                  accent: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.value,
    required this.label,
    this.accent = false,
  });

  final int value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accent ? AppColors.primaryLight : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: AppTypography.liveCounter.copyWith(
              fontSize: 26,
              color: isDark ? color : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarStreak extends StatelessWidget {
  const _AppBarStreak({required this.streak, required this.onTap});

  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Tooltip(
        message: 'Smoke-free streak',
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.accentStreak,
                  size: 22,
                ),
                const SizedBox(width: 2),
                Text(
                  '$streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
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

class _QuickLogCard extends StatelessWidget {
  const _QuickLogCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? AppColors.relapse.withValues(alpha: 0.12)
                : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.relapse),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need to log?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Private, quick, and shame-free.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.checkedIn,
    required this.smokeFreeToday,
    required this.onTap,
  });

  final bool checkedIn;
  final bool? smokeFreeToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = checkedIn ? 'Check-in complete' : 'Daily check-in';
    final body = checkedIn
        ? (smokeFreeToday == true
              ? 'Today is marked smoke-free.'
              : 'Today is logged honestly. That still counts.')
        : 'One minute: Log your daily progress.';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: checkedIn
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? (checkedIn
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.outlineVariant)
                : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              checkedIn
                  ? Icons.check_circle_rounded
                  : Icons.calendar_today_rounded,
              size: 22,
              color: checkedIn
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _BreathingCravingButton extends StatefulWidget {
  const _BreathingCravingButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_BreathingCravingButton> createState() =>
      _BreathingCravingButtonState();
}

class _BreathingCravingButtonState extends State<_BreathingCravingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.018).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scale,
      child: FilledButton(
        onPressed: widget.onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.air_rounded, size: 30),
            const SizedBox(width: AppSpacing.md),
            Text(
              "I'm craving",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final String suffix;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.2) : Colors.white,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.navInk.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 20, color: color),
                const Spacer(),
                if (onTap != null) const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: theme.textTheme.titleSmall),
            Text(
              suffix,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
