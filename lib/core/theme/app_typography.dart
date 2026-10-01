import 'package:flutter/material.dart';

/// Type system: a light, high-contrast serif (Playfair Display at regular
/// weight) for headlines and big numbers, with italic emphasis for the one
/// word that matters; Geist for everything functional. Both are bundled variable fonts (assets/fonts), so
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


  /// Lining figures: Playfair defaults to old-style digits, which sit at
  /// lowercase height and look shrunken next to words ("$6", "0"). Every
  /// serif style turns them on so numbers anywhere in the app are full height.
  static const lining = [FontFeature.liningFigures()];

  // Numbers use the same serif as the headlines, at regular weight, the way
  // Still sets "5 days" and "70%": calm and elegant rather than heavy.

  /// Large hero numbers (streak days, detail heroes).
  static TextStyle get displayNumber =>
      _display(fontSize: 64, height: 1, letterSpacing: -1.5);

  /// Numbers inside stat tiles.
  static TextStyle get statNumber =>
      _display(fontSize: 32, height: 1.1, letterSpacing: -0.6);

  /// Small numbers in compact tiles and rows.
  static TextStyle get miniNumber =>
      _display(fontSize: 24, height: 1.15, letterSpacing: -0.3);

  /// Live ticking counters (timer pills). Each digit rolls in its own box, so
  /// proportional figures do not jitter.
  static TextStyle get liveCounter =>
      _display(fontSize: 30, height: 1.1, letterSpacing: -0.4);

  /// The italic emphasis used for the key word of a headline.
  static TextStyle emphasis(TextStyle? base, Color color) =>
      (base ?? const TextStyle()).copyWith(
        fontStyle: FontStyle.italic,
        color: color,
      );

  /// Small uppercase eyebrow ("WHEN THE WAVE HITS").
  static TextStyle get eyebrow =>
      _body(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.4);

  static TextStyle get liveCounterLabel =>
      _body(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2);

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
      titleLarge: _display(fontSize: 22, height: 28 / 22),
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
      bodyLarge: _body(fontSize: 16, height: 26 / 16, letterSpacing: 0.15),
      bodyMedium: _body(fontSize: 14, height: 22 / 14, letterSpacing: 0.15),
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

  static TextStyle _display({
    required double fontSize,
    required double height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontVariations: w400,
      height: height,
      letterSpacing: letterSpacing ?? (fontSize >= 28 ? -0.5 : -0.2),
      fontFeatures: lining,
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
