import 'package:flutter/material.dart';

import '../layout/window_size.dart';

/// Centers [child] and caps its width so content stays readable on tablets,
/// foldables and landscape phones. On phones it has no visible effect.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    required this.child,
    this.maxWidth = kMaxContentWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
