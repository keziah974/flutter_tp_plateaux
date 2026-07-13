import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_model.dart';

/// Construit le [ThemeData] Material complet pour chacun des 3 thèmes.
class AppTheme {
  AppTheme._();

  static ThemeData of(AppThemeType type) {
    final colors = AppColors.of(type);
    final typography = AppTypography.of(type);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.accent,
        surface: colors.surface,
        onPrimary: colors.background,
        onSecondary: colors.textPrimary,
        onSurface: colors.textPrimary,
        error: colors.accent,
      ),
      textTheme: TextTheme(
        displayLarge: typography.displayLarge,
        displayMedium: typography.displayMedium,
        headlineMedium: typography.displayMedium,
        titleLarge: typography.displayMedium,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        labelLarge: typography.labelLarge,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.displayMedium,
        iconTheme: IconThemeData(color: colors.primary),
      ),
      iconTheme: IconThemeData(color: colors.primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface.withValues(alpha: 0.6),
        hintStyle: typography.bodyMedium,
        labelStyle: typography.bodyMedium,
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.primary.withValues(alpha: 0.2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        titleTextStyle: typography.displayMedium,
        contentTextStyle: typography.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: typography.bodyLarge,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
