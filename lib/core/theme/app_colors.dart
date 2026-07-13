import 'package:flutter/material.dart';

import 'theme_model.dart';

/// Palette complète d'un thème. Toutes les couleurs utilisées par l'UI
/// passent par ici — jamais de couleur en dur dans les widgets.
class AppColors {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color boardLight;
  final Color boardDark;
  final Color piece1;
  final Color piece2;
  final Color boardBorder;
  final Color winHighlight;

  const AppColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.boardLight,
    required this.boardDark,
    required this.piece1,
    required this.piece2,
    required this.boardBorder,
    required this.winHighlight,
  });

  /// Thème 1 — Futuriste « NéoGrid »
  static const AppColors futuriste = AppColors(
    background: Color(0xFF0A0E1A),
    surface: Color(0xFF121A2E),
    primary: Color(0xFF00F5FF),
    secondary: Color(0xFF7B2FFF),
    accent: Color(0xFFFF2D78),
    textPrimary: Color(0xFFEAF6FF),
    textSecondary: Color(0xFF8A94B8),
    boardLight: Color(0xFF16203A),
    boardDark: Color(0xFF0D1426),
    piece1: Color(0xFF00F5FF),
    piece2: Color(0xFFFF2D78),
    boardBorder: Color(0xFF00F5FF),
    winHighlight: Color(0xFF7B2FFF),
  );

  /// Thème 2 — Ancien « Bois & Pierre »
  static const AppColors ancien = AppColors(
    background: Color(0xFF2C1810),
    surface: Color(0xFF3E2418),
    primary: Color(0xFFC8860A),
    secondary: Color(0xFF8B4513),
    accent: Color(0xFFF5DEB3),
    textPrimary: Color(0xFFF5DEB3),
    textSecondary: Color(0xFFC9A97C),
    boardLight: Color(0xFFDDB579),
    boardDark: Color(0xFF6B3E1E),
    piece1: Color(0xFF3B2412),
    piece2: Color(0xFFF0D9A8),
    boardBorder: Color(0xFFC8860A),
    winHighlight: Color(0xFFC8860A),
  );

  /// Thème 3 — Espace « Cosmos »
  static const AppColors cosmos = AppColors(
    background: Color(0xFF05010F),
    surface: Color(0xFF120B2E),
    primary: Color(0xFFFFD700),
    secondary: Color(0xFF4169E1),
    accent: Color(0xFFFF6B35),
    textPrimary: Color(0xFFF4F0FF),
    textSecondary: Color(0xFF9AA4D0),
    boardLight: Color(0x2EFFFFFF),
    boardDark: Color(0x14FFFFFF),
    piece1: Color(0xFF4169E1),
    piece2: Color(0xFFFF6B35),
    boardBorder: Color(0xFFFFD700),
    winHighlight: Color(0xFFFFD700),
  );

  static AppColors of(AppThemeType type) {
    switch (type) {
      case AppThemeType.futuriste:
        return futuriste;
      case AppThemeType.ancien:
        return ancien;
      case AppThemeType.cosmos:
        return cosmos;
    }
  }
}
