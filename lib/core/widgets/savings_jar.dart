import 'package:flutter/material.dart';

import '../theme/app_accents.dart';

/// A jar filled to [fill] (0 to 1). With [coinDrop] set, a coin is drawn that
/// distance (0 to 1) along its fall into the jar.
class SavingsJar extends StatelessWidget {
  const SavingsJar({required this.fill, this.coinDrop, super.key});

  final double fill;
  final double? coinDrop;

  @override
  Widget build(BuildContext context) {
    final accents = AppAccents.of(context);

    return CustomPaint(
      size: Size.infinite,
      painter: _SavingsJarPainter(
        fill: fill.clamp(0.0, 1.0),
        coinDrop: coinDrop,
        jar: accents.money,
        contents: accents.moneyContainer,
      ),
    );
  }
}

class _SavingsJarPainter extends CustomPainter {
  const _SavingsJarPainter({
    required this.fill,
    required this.coinDrop,
    required this.jar,
    required this.contents,
  });

  final double fill;
  final double? coinDrop;
  final Color jar;
  final Color contents;

  @override
  void paint(Canvas canvas, Size size) {
    const jarWidth = 96.0;
    const coinRadius = 13.0;
    // Leave room above the jar for the coin to fall through.
    final jarHeight = (size.height - (coinDrop == null ? 8 : 50)).clamp(
      40.0,
      110.0,
    );
    final jarRect = Rect.fromLTWH(
      (size.width - jarWidth) / 2,
      size.height - jarHeight - 4,
      jarWidth,
      jarHeight,
    );
    final jarShape = RRect.fromRectAndCorners(
      jarRect,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(26),
      bottomRight: const Radius.circular(26),
    );
    final level = jarHeight * fill;

    canvas.save();
    canvas.clipRRect(jarShape);
    canvas.drawRect(
      Rect.fromLTWH(jarRect.left, jarRect.bottom - level, jarWidth, level),
      Paint()..color = contents,
    );
    canvas.restore();

    final drop = coinDrop;
    if (drop != null) {
      final restY = (jarRect.bottom - level - coinRadius + 4).clamp(
        jarRect.top + coinRadius,
        jarRect.bottom - coinRadius - 4,
      );
      final center = Offset(
        size.width / 2,
        coinRadius + (restY - coinRadius) * drop.clamp(0.0, 1.0),
      );
      canvas.drawCircle(center, coinRadius, Paint()..color = jar);
      canvas.drawCircle(
        center,
        coinRadius - 5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = contents,
      );
    }

    canvas.drawRRect(
      jarShape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = jar,
    );
  }

  @override
  bool shouldRepaint(covariant _SavingsJarPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.coinDrop != coinDrop ||
        oldDelegate.jar != jar ||
        oldDelegate.contents != contents;
  }
}
