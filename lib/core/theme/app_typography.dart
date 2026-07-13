import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'theme_model.dart';

/// Styles de texte pré-définis pour un thème donné.
/// Futuriste : Orbitron (titres) + Exo 2 (texte)
/// Ancien : Cinzel (titres) + Lora (texte)
/// Cosmos : Space Grotesk (tout)
class AppTypography {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;

  const AppTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
  });

  static AppTypography of(AppThemeType type) {
    final colors = AppColors.of(type);
    switch (type) {
      case AppThemeType.futuriste:
        return AppTypography(
          displayLarge: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: colors.textPrimary,
          ),
          displayMedium: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: colors.textPrimary,
          ),
          bodyLarge: GoogleFonts.exo2(
            fontSize: 16,
            color: colors.textPrimary,
          ),
          bodyMedium: GoogleFonts.exo2(
            fontSize: 14,
            color: colors.textSecondary,
          ),
          labelLarge: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: colors.textPrimary,
          ),
        );
      case AppThemeType.ancien:
        return AppTypography(
          displayLarge: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
          displayMedium: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          bodyLarge: GoogleFonts.lora(
            fontSize: 16,
            color: colors.textPrimary,
          ),
          bodyMedium: GoogleFonts.lora(
            fontSize: 14,
            color: colors.textSecondary,
          ),
          labelLarge: GoogleFonts.cinzel(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        );
      case AppThemeType.cosmos:
        return AppTypography(
          displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: colors.textPrimary,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          bodyLarge: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: colors.textPrimary,
          ),
          bodyMedium: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: colors.textSecondary,
          ),
          labelLarge: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: colors.textPrimary,
          ),
        );
    }
  }
}
