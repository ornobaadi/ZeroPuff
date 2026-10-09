import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../calculations/day_history.dart';

/// One day as a small mark: smoke-free, sealed, slipped, today, or not part
/// of the quit yet. Shape and icon carry the meaning, not color alone.
class DayDot extends StatelessWidget {
  const DayDot({required this.state, this.size = 32, super.key});

  final DayState state;
  final double size;

  /// How the day reads aloud.
  static String describe(DayState state) {
    return switch (state.kind) {
      DayKind.future => 'upcoming',
      DayKind.beforeQuit => 'before your quit date',
      DayKind.slipped => 'smoked',
      DayKind.smokeFree =>
        state.sealed
            ? 'smoke-free, sealed'
            : state.isToday
            ? 'today, not sealed yet'
            : 'smoke-free',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconSize = size * 0.56;

    final (
      Color fill,
      Color border,
      double borderWidth,
      Widget? mark,
    ) = switch (state.kind) {
      DayKind.future => (Colors.transparent, Colors.transparent, 0.0, null),
      DayKind.beforeQuit => (
        Colors.transparent,
        scheme.outlineVariant,
        1.0,
        null,
      ),
      DayKind.slipped => (
        scheme.tertiaryContainer,
        scheme.tertiary,
        1.5,
        Icon(
          Symbols.circle_rounded,
          size: size * 0.28,
          fill: 1,
          color: scheme.tertiary,
        ),
      ),
      DayKind.smokeFree =>
        state.sealed
            ? (
                scheme.primary,
                scheme.primary,
                0.0,
                Icon(
                  Symbols.check_rounded,
                  size: iconSize,
                  weight: 700,
                  color: scheme.onPrimary,
                ),
              )
            : state.isToday
            ? (Colors.transparent, scheme.primary, 2.0, null)
            : (
                scheme.primaryContainer,
                scheme.primaryContainer,
                0.0,
                Icon(
                  Symbols.check_rounded,
                  size: iconSize,
                  color: scheme.onPrimaryContainer,
                ),
              ),
    };

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: borderWidth == 0
              ? null
              : Border.all(color: border, width: borderWidth),
        ),
        child: mark == null ? null : Center(child: mark),
      ),
    );
  }
}
