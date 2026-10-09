import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../services/haptics/haptic_service.dart';

const _inhale = Duration(seconds: 4);
const _exhale = Duration(seconds: 6);

/// How full the breath in has to be before letting go counts as a breath.
const _minimumBreath = 0.45;

enum _BreathPhase { idle, inhaling, exhaling, tooShort }

/// Press and hold to breathe in, let go to breathe out.
///
/// The orb swells while held and the phone hums upward with it; on release it
/// settles, loose particles drift away and the hum fades. A breath counts when
/// the breath out finishes. With [auto] on, the orb paces the breaths itself so
/// it can be followed by feel alone.
class BreathOrb extends StatefulWidget {
  const BreathOrb({
    required this.onBreath,
    required this.hapticsEnabled,
    this.auto = false,
    this.dimmed = false,
    super.key,
  });

  final VoidCallback onBreath;
  final bool hapticsEnabled;

  /// Paces the breathing without touch.
  final bool auto;

  /// Draws for a dark, pocketed screen: no labels, muted colors.
  final bool dimmed;

  @override
  State<BreathOrb> createState() => _BreathOrbState();
}

class _BreathOrbState extends State<BreathOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  _BreathPhase _phase = _BreathPhase.idle;
  bool _counts = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _inhale)
      ..addStatusListener(_onStatus);
    if (widget.auto) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startInhale());
    }
  }

  @override
  void didUpdateWidget(covariant BreathOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.auto && !oldWidget.auto && _phase == _BreathPhase.idle) {
      _startInhale();
    }
  }

  @override
  void dispose() {
    HapticService.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.auto) {
      _startExhale();
      return;
    }
    if (status != AnimationStatus.dismissed) {
      return;
    }
    final counted = _counts;
    _counts = false;
    setState(() => _phase = _BreathPhase.idle);
    if (counted) {
      widget.onBreath();
    }
    if (widget.auto && mounted) {
      _startInhale();
    }
  }

  void _startInhale() {
    if (!mounted || _phase == _BreathPhase.inhaling) {
      return;
    }
    final remaining = _inhale * (1 - _controller.value);
    setState(() => _phase = _BreathPhase.inhaling);
    HapticService.inhale(enabled: widget.hapticsEnabled, duration: remaining);
    _controller.animateTo(1, duration: remaining, curve: Curves.easeOut);
  }

  void _startExhale() {
    if (!mounted || _phase != _BreathPhase.inhaling) {
      return;
    }
    final fullEnough = _controller.value >= _minimumBreath;
    _counts = fullEnough;
    setState(
      () => _phase = fullEnough ? _BreathPhase.exhaling : _BreathPhase.tooShort,
    );
    final duration = fullEnough
        ? _exhale * _controller.value
        : const Duration(milliseconds: 500);
    if (fullEnough) {
      HapticService.exhale(enabled: widget.hapticsEnabled, duration: duration);
    } else {
      HapticService.cancel();
    }
    _controller.animateBack(0, duration: duration, curve: Curves.easeInOut);
  }

  String get _label => switch (_phase) {
    _BreathPhase.idle => 'Hold to breathe in',
    _BreathPhase.inhaling => 'Breathe in',
    _BreathPhase.exhaling => 'Breathe out',
    _BreathPhase.tooShort => 'Hold a little longer',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduced = AppMotion.reduced(context);

    final orb = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbPainter(
            fill: _controller.value,
            exhaling: _phase == _BreathPhase.exhaling,
            still: reduced,
            orb: widget.dimmed
                ? scheme.primary.withValues(alpha: 0.35)
                : scheme.primaryContainer,
            ring: widget.dimmed
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.primary,
            guide: widget.dimmed
                ? Colors.transparent
                : scheme.outlineVariant,
            particle: scheme.tertiary,
          ),
          child: Center(
            child: widget.dimmed
                ? null
                : Text(
                    widget.auto && _phase == _BreathPhase.idle
                        ? 'Breathe in'
                        : _label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
          ),
        );
      },
    );

    if (widget.auto) {
      return Semantics(
        liveRegion: true,
        label: 'Paced breathing. $_label',
        child: ExcludeSemantics(child: orb),
      );
    }

    return Semantics(
      button: true,
      label:
          'Breathing orb. Press and hold to breathe in, release to breathe out.',
      // A hold is awkward with a screen reader, so a tap runs one paced breath.
      onTap: () {
        _startInhale();
        Future<void>.delayed(_inhale, _startExhale);
      },
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _startInhale(),
          onTapUp: (_) => _startExhale(),
          onTapCancel: _startExhale,
          child: orb,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({
    required this.fill,
    required this.exhaling,
    required this.still,
    required this.orb,
    required this.ring,
    required this.guide,
    required this.particle,
  });

  /// 0 is empty lungs, 1 is a full breath.
  final double fill;
  final bool exhaling;
  final bool still;
  final Color orb;
  final Color ring;
  final Color guide;
  final Color particle;

  static const _particles = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final full = math.min(size.width, size.height) / 2 - 8;
    if (full <= 0) {
      return;
    }
    final scale = still ? 0.8 : 0.5 + 0.5 * fill;
    final radius = full * scale;

    // The size of a full breath, so there is something to grow into.
    canvas.drawCircle(
      center,
      full,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = guide,
    );

    if (exhaling && !still) {
      _paintParticles(canvas, center, full);
    }

    canvas.drawCircle(center, radius, Paint()..color = orb);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + 3 * fill
        ..color = ring,
    );
  }

  /// Specks that leave the orb and thin out as the breath empties.
  void _paintParticles(Canvas canvas, Offset center, double full) {
    final released = 1 - fill;
    final paint = Paint();
    for (var index = 0; index < _particles; index++) {
      final seed = index / _particles;
      // Stagger the specks so they do not all leave at once.
      final t = ((released * 1.6) - seed * 0.6).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) {
        continue;
      }
      final angle = -math.pi / 2 + (seed - 0.5) * 2.4 + math.sin(index * 2.3) * 0.3;
      final distance = full * (0.55 + 0.75 * t);
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      paint.color = particle.withValues(alpha: 0.5 * (1 - t));
      canvas.drawCircle(offset, 3 + 5 * (1 - t), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.exhaling != exhaling ||
        oldDelegate.still != still ||
        oldDelegate.orb != orb ||
        oldDelegate.ring != ring ||
        oldDelegate.guide != guide;
  }
}
