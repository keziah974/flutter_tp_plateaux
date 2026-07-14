import 'package:flutter/material.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Logo « Game Board » stylé selon le thème actif.
class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final typography = context.appTypography;
    final base = typography.displayLarge.copyWith(fontSize: fontSize);

    switch (type) {
      case AppThemeType.futuriste:
        return Text(
          'GAME BOARD',
          textAlign: TextAlign.center,
          style: base.copyWith(
            color: colors.primary,
            shadows: [
              Shadow(
                color: colors.primary.withValues(alpha: 0.8),
                blurRadius: 18,
              ),
              Shadow(
                color: colors.secondary.withValues(alpha: 0.6),
                blurRadius: 32,
              ),
            ],
          ),
        );
      case AppThemeType.ancien:
        return Text(
          'Game Board',
          textAlign: TextAlign.center,
          style: base.copyWith(
            color: colors.primary,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 4,
                offset: const Offset(2, 3),
              ),
            ],
          ),
        );
      case AppThemeType.cosmos:
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [colors.primary, colors.accent, colors.secondary],
          ).createShader(bounds),
          child: Text(
            'Game Board',
            textAlign: TextAlign.center,
            style: base.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: colors.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        );
    }
  }
}
