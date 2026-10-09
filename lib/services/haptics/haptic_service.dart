import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// How big a milestone is, which decides how its celebration feels.
enum MilestoneWeight { small, medium, large }

class HapticService {
  const HapticService._();

  static const _channel = MethodChannel('zeropuff/haptics');

  static Future<void> selection({required bool enabled}) {
    if (!enabled) {
      return Future.value();
    }
    return HapticFeedback.selectionClick();
  }

  static Future<void> light({required bool enabled}) {
    if (!enabled) {
      return Future.value();
    }
    return HapticFeedback.lightImpact();
  }

  static Future<void> medium({required bool enabled}) {
    if (!enabled) {
      return Future.value();
    }
    return HapticFeedback.mediumImpact();
  }

  static Future<void> success({required bool enabled}) {
    if (!enabled) {
      return Future.value();
    }
    return HapticFeedback.heavyImpact();
  }

  /// A vibration that slowly rises for as long as the breath in lasts.
  static Future<void> inhale({
    required bool enabled,
    Duration duration = const Duration(seconds: 4),
  }) {
    return _play(
      'inhale',
      enabled: enabled,
      duration: duration,
      fallback: HapticFeedback.lightImpact,
    );
  }

  /// A vibration that fades away over the breath out.
  static Future<void> exhale({
    required bool enabled,
    Duration duration = const Duration(seconds: 6),
  }) {
    return _play(
      'exhale',
      enabled: enabled,
      duration: duration,
      fallback: HapticFeedback.selectionClick,
    );
  }

  /// The smallest tap: a digit rolling over, a target touched.
  static Future<void> tick({required bool enabled}) {
    return _play(
      'tick',
      enabled: enabled,
      fallback: HapticFeedback.selectionClick,
    );
  }

  /// A coin landing in the savings jar.
  static Future<void> coin({required bool enabled}) {
    return _play(
      'coin',
      enabled: enabled,
      fallback: HapticFeedback.mediumImpact,
    );
  }

  /// Two beats, stronger the longer the streak ([strength] from 0 to 1).
  static Future<void> heartbeat({required bool enabled, double strength = 1}) {
    return _play(
      'heartbeat',
      enabled: enabled,
      scale: 0.35 + 0.65 * strength.clamp(0, 1),
      fallback: HapticFeedback.lightImpact,
    );
  }

  static Future<void> milestone({
    required bool enabled,
    MilestoneWeight weight = MilestoneWeight.small,
  }) {
    return _play(
      'milestone_${weight.name}',
      enabled: enabled,
      fallback: HapticFeedback.heavyImpact,
    );
  }

  /// Stops a breath vibration that is still playing.
  static Future<void> cancel() async {
    if (!_hasChannel) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('cancel');
    } on MissingPluginException {
      // Nothing is playing where the channel does not exist.
    } on PlatformException {
      // Same: there is nothing to stop.
    }
  }

  static bool get _hasChannel =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> _play(
    String pattern, {
    required bool enabled,
    required Future<void> Function() fallback,
    Duration? duration,
    double scale = 1,
  }) async {
    if (!enabled) {
      return;
    }
    if (_hasChannel) {
      try {
        await _channel.invokeMethod<void>('play', {
          'pattern': pattern,
          'durationMs': ?duration?.inMilliseconds,
          'scale': scale,
        });
        return;
      } on MissingPluginException {
        // Fall through to the basic system feedback.
      } on PlatformException {
        // Device without shaped vibration: fall through.
      }
    }
    await fallback();
  }
}
