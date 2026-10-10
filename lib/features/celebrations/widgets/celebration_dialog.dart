import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../milestone_celebration_controller.dart';

/// How long the badge has to be held before it is claimed.
const _holdTime = Duration(milliseconds: 1300);

/// The celebratory moment in the app, and something the user does rather than
/// reads. The badge arrives locked; holding it fills a ring, the same gesture
/// as the rescue, and when the ring closes the badge snaps free with a burst
/// of shards like the ones in the logo.
///
/// A tap from a screen reader, or reduced motion, claims it straight away.
class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({
    required this.event,
    this.onShare,
    this.onHoldTick,
    this.onClaimed,
    super.key,
  });

  final CelebrationEvent event;

  /// Offers to share the win when set.
  final VoidCallback? onShare;

  /// Called a few times while the badge is held, for a rising haptic.
  final VoidCallback? onHoldTick;

  /// Called once, as the badge is claimed.
  final VoidCallback? onClaimed;

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _hold;
  late final AnimationController _burst;
  bool _claimed = false;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _hold = AnimationController(vsync: this, duration: _holdTime)
      ..addListener(_onHold)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _claim();
        }
      });
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _hold.dispose();
    _burst.dispose();
    super.dispose();
  }

  /// A tick at each quarter of the hold, so it can be felt building.
  void _onHold() {
    final ticks = (_hold.value * 4).floor();
    if (ticks > _ticks && ticks < 4) {
      widget.onHoldTick?.call();
    }
    _ticks = ticks;
  }

  void _press() {
    if (_claimed) {
      return;
    }
    if (AppMotion.reduced(context)) {
      _claim();
    } else {
      _hold.forward();
    }
  }

  void _release() {
    if (!_claimed) {
      _hold.reverse();
    }
  }

  void _claim() {
    if (_claimed) {
      return;
    }
    widget.onClaimed?.call();
    setState(() => _claimed = true);
    if (AppMotion.reduced(context)) {
      _burst.value = 1;
    } else {
      _burst.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final event = widget.event;
    final isMilestone = event.kind == CelebrationKind.milestone;
    final container = isMilestone
        ? accents.moneyContainer
        : scheme.primaryContainer;
    final onContainer = isMilestone
        ? accents.onMoneyContainer
        : scheme.onPrimaryContainer;

    final badge = DecoratedBox(
      decoration: BoxDecoration(color: container, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 148,
        child: event.badgeAsset == null
            ? Icon(event.icon, size: 64, color: onContainer)
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Image.asset(event.badgeAsset!, fit: BoxFit.contain),
              ),
      ),
    );

    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Symbols.close_rounded),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMilestone ? 'MILESTONE REACHED' : 'BADGE EARNED',
                        style: AppTypography.eyebrow.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Semantics(
                        button: !_claimed,
                        label: _claimed
                            ? '${event.title}, claimed'
                            : '${event.title}. Double tap to claim it.',
                        excludeSemantics: true,
                        onTap: _claimed ? null : _claim,
                        child: Listener(
                          onPointerDown: (_) => _press(),
                          onPointerUp: (_) => _release(),
                          onPointerCancel: (_) => _release(),
                          child: SizedBox.square(
                            key: const ValueKey('claim-badge'),
                            dimension: 260,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_hold, _burst]),
                              builder: (context, child) {
                                // Pressed in while held, then a pop past
                                // full size as it comes free.
                                final scale = _claimed
                                    ? 1 +
                                          0.12 *
                                              math.sin(
                                                Curves.easeOut.transform(
                                                      _burst.value,
                                                    ) *
                                                    math.pi,
                                              )
                                    : 1 - 0.08 * _hold.value;
                                return CustomPaint(
                                  painter: _ClaimPainter(
                                    hold: _claimed ? 1 : _hold.value,
                                    burst: _burst.value,
                                    track: scheme.surfaceContainerHighest,
                                    ring: scheme.primary,
                                    shard: accents.money,
                                  ),
                                  child: Center(
                                    child: Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: _claimed
                                            ? 1
                                            : 0.45 + 0.55 * _hold.value,
                                        child: child,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: badge,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        liveRegion: true,
                        child: AnimatedSwitcher(
                          duration: AppMotion.reduced(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 350),
                          child: _claimed
                              ? Column(
                                  key: const ValueKey('claimed'),
                                  children: [
                                    Text(
                                      event.title,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      event.body,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('locked'),
                                  children: [
                                    Text(
                                      'Hold to claim it',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'You earned this one. Press the badge and keep holding.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Kept in the layout while locked, so nothing jumps on the claim.
            Visibility(
              visible: _claimed,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  0,
                  AppSpacing.pagePadding,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Keep going'),
                    ),
                    if (widget.onShare != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton.icon(
                        onPressed: widget.onShare,
                        icon: const Icon(Symbols.ios_share_rounded),
                        label: const Text('Share it'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The ring that fills while the badge is held, and the shards that fly out
/// when it is claimed.
class _ClaimPainter extends CustomPainter {
  const _ClaimPainter({
    required this.hold,
    required this.burst,
    required this.track,
    required this.ring,
    required this.shard,
  });

  final double hold;
  final double burst;
  final Color track;
  final Color ring;
  final Color shard;

  static const _shards = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 34;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, stroke..color = track);
    if (hold > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * hold,
        false,
        stroke..color = ring,
      );
    }

    if (burst <= 0 || burst >= 1) {
      return;
    }
    // Square shards thrown outward, turning as they go and shrinking away.
    final out = Curves.easeOutCubic.transform(burst);
    final paint = Paint()..color = shard;
    for (var index = 0; index < _shards; index++) {
      final angle = index / _shards * math.pi * 2 + 0.3;
      // Every other shard is smaller and travels a little less far.
      final big = index.isEven;
      final distance = radius + (big ? 34 : 20) * out;
      final side = (big ? 12.0 : 8.0) * (1 - burst);
      canvas
        ..save()
        ..translate(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        )
        ..rotate(angle + out * math.pi)
        ..drawRect(
          Rect.fromCenter(center: Offset.zero, width: side, height: side),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ClaimPainter oldDelegate) {
    return oldDelegate.hold != hold ||
        oldDelegate.burst != burst ||
        oldDelegate.track != track ||
        oldDelegate.ring != ring ||
        oldDelegate.shard != shard;
  }
}
