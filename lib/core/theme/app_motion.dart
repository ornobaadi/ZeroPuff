import 'package:flutter/material.dart';

/// Motion tokens (Material 3 easing + duration) and reduced-motion support.
class AppMotion {
  const AppMotion._();

  static const short = Durations.short3; // 150 ms
  static const fast = Duration(milliseconds: 160);
  static const standard = Durations.medium1; // 250 ms
  static const emphasized = Durations.medium4; // 400 ms
  static const slow = Durations.long1; // 450 ms

  /// Spatial movement and shape changes: decelerate into place.
  static const Curve enter = Easing.emphasizedDecelerate;
  static const Curve exit = Easing.emphasizedAccelerate;

  /// Simple state changes (fades, color).
  static const Curve standardCurve = Easing.standard;

  /// True when the user asked the system to remove animations.
  static bool reduced(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// [duration], or [Duration.zero] when animations are disabled.
  static Duration of(BuildContext context, [Duration duration = standard]) {
    return reduced(context) ? Duration.zero : duration;
  }
}
