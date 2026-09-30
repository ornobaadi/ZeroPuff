import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';

/// A glass that fills as the step progresses.
class WaterVisual extends StatelessWidget {
  const WaterVisual({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'A glass of water filling up',
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

/// A slowly expanding and contracting circle to breathe with. With reduced
/// motion turned on it is a still circle with plain written guidance.
class BreathingVisual extends StatefulWidget {
  const BreathingVisual({super.key});

  @override
  State<BreathingVisual> createState() => _BreathingVisualState();
}

class _BreathingVisualState extends State<BreathingVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (AppMotion.reduced(context)) {
      return Semantics(
        label: 'Breathe in slowly, hold, then breathe out for longer',
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primaryContainer,
            border: Border.all(color: scheme.primary, width: 3),
          ),
          child: SizedBox(
            width: 154,
            height: 154,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'In, hold,\nlong out',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final phase = _controller.value;
          final scale = phase < 0.42
              ? 0.72 + (phase / 0.42) * 0.28
              : phase < 0.58
              ? 1.0
              : 1 - ((phase - 0.58) / 0.42) * 0.28;
          final label = phase < 0.42
              ? 'Inhale'
              : phase < 0.58
              ? 'Hold'
              : 'Exhale';

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                    border: Border.all(color: scheme.primary, width: 3),
                  ),
                  child: const SizedBox(width: 154, height: 154),
                ),
              ),
              Text(
                label,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A figure that moves along a track as the step progresses.
class WalkVisual extends StatelessWidget {
  const WalkVisual({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = progress.clamp(0, 1).toDouble();

    return Semantics(
      label: 'Walking progress ${(value * 100).round()} percent',
      child: SizedBox(
        width: 210,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: AppMotion.of(context, AppMotion.slow),
              curve: AppMotion.enter,
              left: 18.0 + (96.0 * value),
              child: Icon(
                Icons.directions_walk_rounded,
                size: 64,
                color: scheme.primary,
              ),
            ),
            Positioned(
              bottom: 28,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final active = value >= index / 4;
                  return AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.fast),
                    width: active ? 28 : 16,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
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
                Icon(Icons.favorite_rounded, color: scheme.primary),
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
