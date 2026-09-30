import 'package:flutter/material.dart';

/// Type system: Playfair Display for display/headline moments, Geist for
/// everything functional. Both are bundled variable fonts (assets/fonts), so
/// the app renders identically offline and never downloads fonts at runtime.
///
/// Variable fonts do not pick a weight from [FontWeight] alone, so every style
/// also carries a matching `wght` variation. When overriding a weight in a
/// `copyWith`, pass the matching constant too, e.g.
/// `copyWith(fontWeight: FontWeight.w700, fontVariations: AppTypography.w700)`.
class AppTypography {
  const AppTypography._();

  static const displayFamily = 'PlayfairDisplay';
  static const bodyFamily = 'Geist';

  static const w400 = [FontVariation('wght', 400)];
  static const w500 = [FontVariation('wght', 500)];
  static const w600 = [FontVariation('wght', 600)];
  static const w700 = [FontVariation('wght', 700)];
  static const w800 = [FontVariation('wght', 800)];
  static const w900 = [FontVariation('wght', 900)];

  static const _tabular = [FontFeature.tabularFigures()];

  /// Large hero numbers (timers, streaks).
  static TextStyle get displayNumber => _body(
    fontSize: 64,
    fontWeight: FontWeight.w600,
    height: 1.05,
    features: _tabular,
  );

  /// Numbers inside stat tiles.
  static TextStyle get statNumber => _body(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.05,
    features: _tabular,
  );

  /// Live ticking counters. Tabular figures stop the digits from jittering.
  static TextStyle get liveCounter => _body(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    features: _tabular,
  );

  static TextStyle get liveCounterLabel => _body(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  /// Material 3 type scale.
  static TextTheme get textTheme {
    final base = Typography.material2021().black;
    return base.copyWith(
      displayLarge: _display(fontSize: 57, height: 64 / 57),
      displayMedium: _display(fontSize: 45, height: 52 / 45),
      displaySmall: _display(fontSize: 36, height: 44 / 36),
      headlineLarge: _display(fontSize: 32, height: 40 / 32),
      headlineMedium: _display(fontSize: 28, height: 36 / 28),
      headlineSmall: _display(fontSize: 24, height: 32 / 24),
      titleLarge: _body(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
      ),
      titleMedium: _body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        letterSpacing: 0.15,
      ),
      titleSmall: _body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
      ),
      bodyLarge: _body(fontSize: 16, height: 24 / 16, letterSpacing: 0.5),
      bodyMedium: _body(fontSize: 14, height: 20 / 14, letterSpacing: 0.25),
      bodySmall: _body(fontSize: 12, height: 16 / 12, letterSpacing: 0.4),
      labelLarge: _body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
      ),
      labelMedium: _body(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.5,
      ),
      labelSmall: _body(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 16 / 11,
        letterSpacing: 0.5,
      ),
    );
  }

  static TextStyle _display({required double fontSize, required double height}) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      fontVariations: w600,
      height: height,
      letterSpacing: 0,
    );
  }

  static TextStyle _body({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    List<FontFeature>? features,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontVariations: [FontVariation('wght', fontWeight.value.toDouble())],
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: features,
    );
  }
}
