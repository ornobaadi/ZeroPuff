import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/calculations/today_card_calculations.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

/// The part of Home that is different every time: what matters right now.
class TodayCardView extends StatelessWidget {
  const TodayCardView({required this.card, this.onAction, super.key});

  final TodayCard card;

  /// Runs the card's button, when it has one.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final urgent = card.kind == TodayCardKind.ritualSoon;

    final (
      IconData icon,
      Color background,
      Color foreground,
      Color accent,
    ) = switch (card.kind) {
      TodayCardKind.ritualSoon => (
        Symbols.schedule_rounded,
        accents.cravingContainer,
        accents.onCravingContainer,
        accents.craving,
      ),
      TodayCardKind.sealDay => (
        Symbols.verified_rounded,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        scheme.primary,
      ),
      TodayCardKind.pledge => (
        Symbols.wb_sunny_rounded,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        scheme.secondary,
      ),
      TodayCardKind.recap => (
        Symbols.military_tech_rounded,
        accents.streakContainer,
        accents.onStreakContainer,
        accents.streak,
      ),
      TodayCardKind.goal => (
        Symbols.savings_rounded,
        accents.moneyContainer,
        accents.onMoneyContainer,
        accents.money,
      ),
      TodayCardKind.insight => (
        Symbols.insights_rounded,
        scheme.surfaceContainerLow,
        scheme.onSurface,
        scheme.primary,
      ),
      TodayCardKind.steady => (
        Symbols.air_rounded,
        scheme.surfaceContainerLow,
        scheme.onSurface,
        scheme.primary,
      ),
    };
    final action = card.actionLabel;
    final progress = card.progress;

    return AppCard(
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Text(
                urgent
                    ? 'RIGHT NOW'
                    : card.kind == TodayCardKind.sealDay
                    ? 'TONIGHT'
                    : 'TODAY',
                style: AppTypography.eyebrow.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            card.title,
            style: theme.textTheme.titleLarge?.copyWith(color: foreground),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            card.body,
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              color: accent,
              backgroundColor: scheme.surface.withValues(alpha: 0.55),
              semanticsLabel: 'Progress to your savings goal',
              semanticsValue: '${(progress * 100).round()} percent',
            ),
          ],
          if (action != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(onPressed: onAction, child: Text(action)),
          ],
        ],
      ),
    );
  }
}
