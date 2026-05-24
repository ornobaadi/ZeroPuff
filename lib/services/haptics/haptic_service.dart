import 'package:flutter/services.dart';

class HapticService {
  const HapticService._();

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
}
