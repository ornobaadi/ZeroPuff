import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shapes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    ).copyWith(
      primary: AppColors.primary,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      error: AppColors.error,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppShapes.card,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AppShapes.button,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: const RoundedRectangleBorder(
            borderRadius: AppShapes.button,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        border: const OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
        selectedColor: AppColors.primaryLight,
        labelStyle: AppTypography.textTheme.labelMedium,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.chip),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.textTheme.labelSmall,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.textPrimary : AppColors.textPrimary,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.input),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.7),
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.sheet),
      ),
    );
  }
}
