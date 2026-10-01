import 'package:flutter/material.dart';

import 'app_accents.dart';
import 'app_colors.dart';
import 'app_shapes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light (linen) and dark (charcoal) Material 3 themes.
///
/// The scheme starts from the seed so every role exists, then the surface,
/// text and primary roles are pinned to the brand palette. Colors that
/// Material has no role for live in [AppAccents].
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = _scheme(brightness);
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      // Material Symbols Rounded: light outlined strokes by default; fill
      // (fill: 1) is reserved for selected/active states.
      iconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        fill: 0,
        weight: 400,
        grade: 0,
        opticalSize: 24,
      ),
      extensions: [
        brightness == Brightness.dark ? AppAccents.dark : AppAccents.light,
      ],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.card),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppShapes.button),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontVariations: AppTypography.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          side: BorderSide(color: scheme.outline, width: 1.5),
          backgroundColor: scheme.surfaceContainerLow,
          foregroundColor: scheme.onSurface,
          shape: const RoundedRectangleBorder(borderRadius: AppShapes.button),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontVariations: AppTypography.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontVariations: AppTypography.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: const OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShapes.input,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        checkmarkColor: scheme.onPrimaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.chip),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontVariations: AppTypography.w700,
          color: scheme.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.medium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.extraLarge),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.sheet),
      ),
      // Thin, calm progress: sage fill on a muted track.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
        linearMinHeight: 4,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppShapes.large),
        iconColor: scheme.onSurfaceVariant,
      ),
    );
  }

  static ColorScheme _scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    if (brightness == Brightness.dark) {
      return base.copyWith(
        primary: AppColors.sage,
        onPrimary: AppColors.darkBackground,
        primaryContainer: const Color(0xFF214433),
        onPrimaryContainer: const Color(0xFFC8EDD6),
        secondary: const Color(0xFFB4CCBD),
        onSecondary: AppColors.darkBackground,
        secondaryContainer: const Color(0xFF2F4A3C),
        onSecondaryContainer: const Color(0xFFD6EEDF),
        tertiary: const Color(0xFFD4A28B),
        onTertiary: AppColors.darkBackground,
        tertiaryContainer: const Color(0xFF453027),
        onTertiaryContainer: const Color(0xFFF2D5C7),
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextMuted,
        surfaceContainerLowest: const Color(0xFF0C0E11),
        surfaceContainerLow: AppColors.darkSurfaceLow,
        surfaceContainer: AppColors.darkSurface,
        surfaceContainerHigh: AppColors.darkSurfaceHigh,
        surfaceContainerHighest: AppColors.darkSurfaceHighest,
        outline: const Color(0xFF4A5459),
        outlineVariant: const Color(0xFF2B3337),
        inverseSurface: AppColors.darkText,
        onInverseSurface: AppColors.darkBackground,
        inversePrimary: AppColors.sageDeep,
      );
    }
    return base.copyWith(
      primary: AppColors.sageDeep,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD5E8DA),
      onPrimaryContainer: const Color(0xFF123222),
      secondary: const Color(0xFF55675C),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE0E6DD),
      onSecondaryContainer: const Color(0xFF1E2A23),
      tertiary: AppColors.terracottaDeep,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFF3DED4),
      onTertiaryContainer: const Color(0xFF3B1E12),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.lightTextMuted,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.lightSurface,
      surfaceContainer: AppColors.lightSurfaceLow,
      surfaceContainerHigh: AppColors.lightSurfaceHigh,
      surfaceContainerHighest: AppColors.lightSurfaceHighest,
      outline: const Color(0xFFBFC4BA),
      outlineVariant: const Color(0xFFDDE0D7),
      inverseSurface: const Color(0xFF242A26),
      onInverseSurface: AppColors.lightSurfaceLow,
      inversePrimary: AppColors.sage,
    );
  }
}
