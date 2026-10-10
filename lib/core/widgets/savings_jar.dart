import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/haptics/haptic_service.dart';
import '../theme/app_accents.dart';
import '../theme/app_motion.dart';

/// A jar with coins piled in it. [fill] (0 to 1) is how full the pile is.
///
/// With [dropCount] set, the top [dropCount] coins of the pile are shown
/// falling in one after another as [dropProgress] goes from 0 to 1. Each one
/// lands in its own place and stays, so the pile ends exactly at [fill].
class SavingsJar extends StatelessWidget {
  const SavingsJar({
    required this.fill,
    this.dropCount = 0,
    this.dropProgress = 1,
    super.key,
  });

  final double fill;
  final int dropCount;
  final double dropProgress;

  @override
  Widget build(BuildContext context) {
    final accents = AppAccents.of(context);

    return CustomPaint(
      size: Size.infinite,
      painter: _SavingsJarPainter(
        fill: fill.clamp(0.0, 1.0),
        dropCount: dropCount,
        dropProgress: dropProgress.clamp(0.0, 1.0),
        glass: accents.money,
        coin: accents.money,
        coinEdge: accents.moneyContainer,
      ),
    );
  }
}

/// A [SavingsJar] that plays coins dropping in.
///
/// On first build the top [drops] coins of the pile fall in and stay.
/// Changing [playCount] drops them again, which is how a tap on the jar
/// replays it.
class CoinDropJar extends StatefulWidget {
  const CoinDropJar({
    required this.fill,
    required this.hapticsEnabled,
    this.drops = 0,
    this.playCount = 0,
    super.key,
  });

  final double fill;
  final int drops;
  final int playCount;
  final bool hapticsEnabled;

  @override
  State<CoinDropJar> createState() => _CoinDropJarState();
}

class _CoinDropJarState extends State<CoinDropJar>
    with SingleTickerProviderStateMixin {
  static const _perCoin = Duration(milliseconds: 420);

  late final AnimationController _controller;
  int _coins = 0;
  int _landed = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)..addListener(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _play(widget.drops);
    }
  }

  @override
  void didUpdateWidget(covariant CoinDropJar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playCount != oldWidget.playCount) {
      _play(math.max(widget.drops, 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play(int coins) {
    _coins = coins;
    _landed = 0;
    if (coins <= 0 || AppMotion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    _controller
      ..duration = _perCoin * coins
      ..forward(from: 0);
  }

  /// One clink as each coin lands.
  void _onTick() {
    if (_coins <= 0) {
      return;
    }
    final landed = (_controller.value * _coins).floor().clamp(0, _coins);
    if (landed > _landed) {
      _landed = landed;
      HapticService.coin(enabled: widget.hapticsEnabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SavingsJar(
          fill: widget.fill,
          dropCount: _coins,
          dropProgress: _controller.value,
        );
      },
    );
  }
}

class _SavingsJarPainter extends CustomPainter {
  const _SavingsJarPainter({
    required this.fill,
    required this.dropCount,
    required this.dropProgress,
    required this.glass,
    required this.coin,
    required this.coinEdge,
  });

  final double fill;
  final int dropCount;
  final double dropProgress;
  final Color glass;
  final Color coin;
  final Color coinEdge;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    // Room above the jar for a coin to fall through.
    final headroom = size.height * 0.22;
    final jarHeight = size.height - headroom - 3;
    final jarWidth = math.min(size.width - 6, jarHeight * 0.92);
    final jar = Rect.fromLTWH(
      (size.width - jarWidth) / 2,
      headroom,
      jarWidth,
      jarHeight,
    );
    final stroke = math.max(2.5, jarWidth * 0.035);
    final body = RRect.fromRectAndCorners(
      jar,
      topLeft: Radius.circular(jarWidth * 0.1),
      topRight: Radius.circular(jarWidth * 0.1),
      bottomLeft: Radius.circular(jarWidth * 0.26),
      bottomRight: Radius.circular(jarWidth * 0.26),
    );

    // Coins sit in staggered rows, like a pile seen from the side.
    final radius = jarWidth / 9.5;
    final inner = jar.deflate(stroke + 2);
    final slots = <Offset>[];
    final rowStep = radius * 1.3;
    var row = 0;
    while (true) {
      final y = inner.bottom - radius - row * rowStep;
      if (y - radius < inner.top + radius * 0.6) {
        break;
      }
      final count = row.isEven ? 4 : 3;
      final span = inner.width - radius * 2;
      for (var index = 0; index < count; index++) {
        final t = count == 1 ? 0.5 : index / (count - 1);
        final inset = row.isEven ? 0.0 : span / 6;
        // A small fixed wobble keeps the pile from looking printed.
        final wobble = math.sin(row * 3.1 + index * 1.7) * radius * 0.12;
        slots.add(
          Offset(
            inner.left + radius + inset + (span - inset * 2) * t + wobble,
            y,
          ),
        );
      }
      row += 1;
    }

    // A jar that is being dropped into holds at least the coins dropping.
    final dropping = math.min(dropCount, slots.length);
    final pile = math.max(
      dropping,
      fill <= 0 ? 0 : (fill * slots.length).round().clamp(1, slots.length),
    );
    // Coins already down: the pile under the drop, plus each one landed.
    final landed = (dropProgress * dropping).floor().clamp(0, dropping);
    final resting = pile - dropping + landed;
    canvas.save();
    canvas.clipRRect(body);
    for (var index = 0; index < resting; index++) {
      _paintCoin(canvas, slots[index], radius);
    }
    canvas.restore();

    if (landed < dropping) {
      final target = slots[resting];
      final start = Offset(target.dx, radius + 1);
      final along = Curves.easeIn.transform((dropProgress * dropping) % 1);
      _paintCoin(canvas, Offset.lerp(start, target, along)!, radius);
    }

    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = glass,
    );
    // The rim, a little wider than the body.
    canvas.drawLine(
      Offset(jar.left - stroke, jar.top),
      Offset(jar.right + stroke, jar.top),
      Paint()
        ..strokeWidth = stroke * 1.6
        ..strokeCap = StrokeCap.round
        ..color = glass,
    );
  }

  void _paintCoin(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = coin);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, radius * 0.16)
        ..color = coinEdge,
    );
    canvas.drawCircle(
      center,
      radius * 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, radius * 0.12)
        ..color = coinEdge,
    );
  }

  @override
  bool shouldRepaint(covariant _SavingsJarPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.dropCount != dropCount ||
        oldDelegate.dropProgress != dropProgress ||
        oldDelegate.glass != glass ||
        oldDelegate.coin != coin ||
        oldDelegate.coinEdge != coinEdge;
  }
}
