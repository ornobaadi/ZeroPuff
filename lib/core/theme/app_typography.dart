import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextStyle get displayNumber => GoogleFonts.outfit(
    fontSize: 64,
    fontWeight: FontWeight.w600,
    height: 1.05,
    letterSpacing: 0,
  );

  static TextStyle get statNumber => GoogleFonts.getFont(
    'Geist',
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: 0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get liveCounter => GoogleFonts.spaceMono(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get liveCounterLabel =>
      _body(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2);

  static TextTheme get textTheme {
    final base = Typography.material2021().black;
    return base.copyWith(
      displayLarge: _heading(fontSize: 57, fontWeight: FontWeight.w600),
      displayMedium: _heading(fontSize: 45, fontWeight: FontWeight.w600),
      displaySmall: _heading(fontSize: 36, fontWeight: FontWeight.w600),
      headlineLarge: _heading(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: _heading(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: _heading(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: _body(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: _body(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: _body(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: _body(fontSize: 16, height: 1.58),
      bodyMedium: _body(fontSize: 14, height: 1.55),
      bodySmall: _body(fontSize: 12, height: 1.5),
      labelLarge: _body(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: _body(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: _body(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }

  static TextStyle _heading({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    double? height,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height ?? 1.18,
    );
  }

  static TextStyle _body({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.getFont(
      'Geist',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
