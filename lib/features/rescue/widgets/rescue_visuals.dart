import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';

/// A glass of water, filled to [progress].
class WaterVisual extends StatelessWidget {
  const WaterVisual({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'A glass of water',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1).toDouble()),
        duration: AppMotion.of(context, AppMotion.slow),
        curve: AppMotion.enter,
        builder: (context, value, _) {
          return CustomPaint(
            size: const Size(150, 170),
            painter: _WaterGlassPainter(
              fill: value,
              glass: scheme.primary,
              water: scheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  const _WaterGlassPainter({
    required this.fill,
    required this.glass,
    required this.water,
  });

  final double fill;
  final Color glass;
  final Color water;

  @override
  void paint(Canvas canvas, Size size) {
    final glassShape = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.24, 8, size.width * 0.52, size.height - 16),
      const Radius.circular(22),
    );
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = glass;
    final waterPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = water;
    final waterHeight = (glassShape.outerRect.height - 14) * fill;
    final waterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        glassShape.outerRect.left + 7,
        glassShape.outerRect.bottom - 7 - waterHeight,
        glassShape.outerRect.width - 14,
        waterHeight,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(waterRect, waterPaint);
    canvas.drawRRect(glassShape, border);
  }

  @override
  bool shouldRepaint(covariant _WaterGlassPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.glass != glass ||
        oldDelegate.water != water;
  }
}

/// The user's own reason for quitting, shown large and calm.
class ReasonVisual extends StatelessWidget {
  const ReasonVisual({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.favorite_rounded, color: scheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
