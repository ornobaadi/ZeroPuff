import 'package:flutter/material.dart';

import '../theme/app_shapes.dart';
import '../theme/app_spacing.dart';

enum AppCardStyle {
  /// Neutral raised surface. The default.
  filled,

  /// Emphasis using the primary container color.
  tonal,

  /// Low-emphasis, bordered surface.
  outlined,
}

/// The one card used across the app. Tappable cards get a ripple, a minimum
/// 48dp target and button semantics automatically.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.style = AppCardStyle.filled,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.color,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final AppCardStyle style;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Overrides the background color (use a color-scheme or [AppAccents] role).
  final Color? color;

  /// Read by screen readers instead of the card's combined text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        color ??
        switch (style) {
          AppCardStyle.filled => scheme.surfaceContainerLow,
          AppCardStyle.tonal => scheme.primaryContainer,
          AppCardStyle.outlined => scheme.surface,
        };
    final side = style == AppCardStyle.outlined
        ? BorderSide(color: scheme.outlineVariant)
        : BorderSide.none;

    Widget card = Material(
      color: background,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.card, side: side),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(padding: padding, child: child),
              ),
            ),
    );

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        container: true,
        excludeSemantics: true,
        child: card,
      );
    }
    return card;
  }
}
