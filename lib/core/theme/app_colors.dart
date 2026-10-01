import 'package:flutter/material.dart';

/// Brand palette ("calm sage on linen / charcoal"). The theme builds its
/// [ColorScheme] from these tokens; screens should read colors from the
/// scheme or [AppAccents], never from here directly.
class AppColors {
  const AppColors._();

  static const seed = Color(0xFF52A675);

  // Sage — the one calming action color.
  static const sage = Color(0xFF6DBE8F);
  static const sageDeep = Color(0xFF2F6B4A);

  // Terracotta — money, impact and gentle warnings.
  static const terracotta = Color(0xFFC28B75);
  static const terracottaDeep = Color(0xFF9A5F48);

  // Dark: matte charcoal.
  static const darkBackground = Color(0xFF0F1214);
  static const darkSurfaceLow = Color(0xFF171B1E);
  static const darkSurface = Color(0xFF1D2225);
  static const darkSurfaceHigh = Color(0xFF252B2F);
  static const darkSurfaceHighest = Color(0xFF2E353A);
  static const darkTrack = Color(0xFF242C2E);
  static const darkText = Color(0xFFE6EAE4);
  static const darkTextMuted = Color(0xFFA4AEB0);

  // Light: warm linen.
  static const lightBackground = Color(0xFFEBECE6);
  static const lightSurfaceLow = Color(0xFFF4F5F0);
  static const lightSurface = Color(0xFFFAFAF7);
  static const lightSurfaceHigh = Color(0xFFE3E5DD);
  static const lightSurfaceHighest = Color(0xFFDADDD3);
  static const lightText = Color(0xFF1C211E);
  static const lightTextMuted = Color(0xFF5C6460);
}
