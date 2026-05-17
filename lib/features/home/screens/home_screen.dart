import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/home_dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboard = ref.watch(homeDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ZeroPuff')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: dashboard.when(
            data: (data) => [
              Text('Smoke-free', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${data.smokeFreeDays} days',
                style: AppTypography.displayNumber,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(data.liveClock, style: AppTypography.liveCounter),
              const SizedBox(height: AppSpacing.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'NOT SMOKED',
                      value: '${data.cigarettesAvoided}',
                      suffix: 'cigarettes',
                      color: AppColors.primary,
                      icon: Icons.smoke_free_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricCard(
                      label: 'SAVED',
                      value:
                          '${data.currencySymbol}${data.moneySaved.toStringAsFixed(0)}',
                      suffix: 'so far',
                      color: AppColors.accentMoney,
                      icon: Icons.savings_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, 
                             size: 18, 
                             color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('TODAY', 
                             style: theme.textTheme.labelMedium?.copyWith(
                               color: theme.colorScheme.onSurfaceVariant,
                               letterSpacing: 0.5,
                             )),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      data.honestyStreakDays > 0
                          ? 'Your baseline is set. If a craving hits, come here first.'
                          : 'Set your baseline to make the counter yours.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.rescue),
                icon: const Icon(Icons.air_rounded, size: 28),
                label: const Text("I'm craving", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
            loading: () => [const Center(child: CircularProgressIndicator())],
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
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.icon,
  });

  final String label;
  final String value;
  final String suffix;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            suffix,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
