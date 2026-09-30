import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../progress/widgets/badge_image.dart';

/// The three colors a [StatTone] resolves to on the current theme.
class ToneColors {
  const ToneColors({
    required this.container,
    required this.onContainer,
    required this.accent,
  });

  /// Tinted surface.
  final Color container;

  /// Text and icons on [container].
  final Color onContainer;

  /// Icons, bars and text drawn on a plain surface.
  final Color accent;

  factory ToneColors.of(BuildContext context, StatTone tone) {
    final scheme = Theme.of(context).colorScheme;
    final accents = AppAccents.of(context);
    return switch (tone) {
      StatTone.primary => ToneColors(
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
        accent: scheme.primary,
      ),
      StatTone.money => ToneColors(
        container: accents.moneyContainer,
        onContainer: accents.onMoneyContainer,
        accent: accents.money,
      ),
      StatTone.streak => ToneColors(
        container: accents.streakContainer,
        onContainer: accents.onStreakContainer,
        accent: accents.streak,
      ),
      StatTone.craving => ToneColors(
        container: accents.cravingContainer,
        onContainer: accents.onCravingContainer,
        accent: accents.craving,
      ),
    };
  }
}

typedef DetailBuilder =
    List<Widget> Function(BuildContext context, HomeDashboardData data);

/// Scaffold shared by the progress detail screens: title, centered content,
/// consistent spacing, and loading/error states.
class DetailScaffold extends ConsumerWidget {
  const DetailScaffold({
    required this.title,
    required this.builder,
    this.gap = AppSpacing.md,
    super.key,
  });

  final String title;
  final DetailBuilder builder;
  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: dashboard.when(
          loading: () => const StateView.loading(),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () => ref.invalidate(homeDashboardProvider),
          ),
          data: (data) => DetailList(gap: gap, children: builder(context, data)),
        ),
      ),
    );
  }
}

/// A padded, width-capped list with even spacing between [children].
class DetailList extends StatelessWidget {
  const DetailList({required this.children, this.gap = AppSpacing.md, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The one big number at the top of a detail screen.
class DetailHero extends StatelessWidget {
  const DetailHero({
    required this.value,
    required this.label,
    required this.icon,
    this.tone = StatTone.primary,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, tone);

    return AppCard(
      color: colors.container,
      semanticLabel: '$value $label',
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.onContainer, size: 32),
          const SizedBox(height: AppSpacing.lg),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.displayNumber.copyWith(
                color: colors.onContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Title + explanation with a leading icon. Tappable when [onTap] is set.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    this.tone = StatTone.primary,
    this.onTap,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;
  final StatTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, tone);

    return AppCard(
      style: AppCardStyle.outlined,
      onTap: onTap,
      semanticLabel: '$title. $body',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.accent),
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
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

/// A small tinted number with a label, for two- and three-up rows.
class MiniStat extends StatelessWidget {
  const MiniStat({
    required this.value,
    required this.label,
    this.tone = StatTone.primary,
    super.key,
  });

  final String value;
  final String label;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = ToneColors.of(context, tone);

    return AppCard(
      color: colors.container,
      semanticLabel: '$label: $value',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Equal-width cells in one row with matching heights.
class EvenRow extends StatelessWidget {
  const EvenRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

/// A large badge with its story, shown when an unlocked badge is tapped.
Future<void> showBadgeDialog(
  BuildContext context, {
  required String? asset,
  required String title,
  required String body,
  String? caption,
  IconData fallbackIcon = Icons.emoji_events_rounded,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeImage(
                asset: asset,
                unlocked: true,
                size: 180,
                fallbackIcon: fallbackIcon,
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nice'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// "3 days", "2 months", "1 year" for milestone thresholds.
String compactDuration(Duration duration) {
  if (duration.inDays >= 365) {
    final years = duration.inDays ~/ 365;
    return years == 1 ? '1 year' : '$years years';
  }
  if (duration.inDays >= 30) {
    final months = duration.inDays ~/ 30;
    return months == 1 ? '1 month' : '$months months';
  }
  if (duration.inDays >= 1) {
    return duration.inDays == 1 ? '1 day' : '${duration.inDays} days';
  }
  if (duration.inHours >= 1) {
    return duration.inHours == 1 ? '1 hour' : '${duration.inHours} hours';
  }
  return duration.inMinutes == 1 ? '1 minute' : '${duration.inMinutes} minutes';
}
