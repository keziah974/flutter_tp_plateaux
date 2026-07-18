import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_context.dart';
import '../../core/theme/theme_model.dart';
import 'components/themed_button.dart';

/// Dialog de fin de partie avec animation d'entrée (scale + fade)
/// et habillage selon le thème :
/// - Futuriste : hologramme (lignes de balayage cyan)
/// - Ancien : parchemin qui se déroule
/// - Cosmos : explosion d'étoiles
class GameOverDialog extends StatelessWidget {
  final String title;
  final String scoreText;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.title,
    required this.scoreText,
    required this.onReplay,
    required this.onMenu,
  });

  /// Affiche le dialog avec sa transition scale + fade.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String scoreText,
    required VoidCallback onReplay,
    required VoidCallback onMenu,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Fin de partie',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (dialogContext, _, _) => GameOverDialog(
        title: title,
        scoreText: scoreText,
        onReplay: onReplay,
        onMenu: onMenu,
      ),
      transitionBuilder: (dialogContext, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final typography = context.appTypography;

    final isAncien = type == AppThemeType.ancien;
    final surfaceColor = isAncien
        ? colors.accent
        : colors.surface.withValues(alpha: 0.92);
    final textColor = isAncien ? const Color(0xFF3B2412) : colors.textPrimary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(isAncien ? 8 : 20),
          border: Border.all(
            color: type == AppThemeType.futuriste
                ? colors.primary.withValues(alpha: 0.8)
                : colors.primary,
            width: type == AppThemeType.futuriste ? 1 : 2,
          ),
          boxShadow: [
            if (type != AppThemeType.ancien)
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.4),
                blurRadius: 30,
              ),
            if (isAncien)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isAncien ? 8 : 20),
          child: Stack(
            children: [
              if (type == AppThemeType.futuriste)
                Positioned.fill(
                  child: CustomPaint(painter: _ScanlinesPainter(colors)),
                ),
              if (type == AppThemeType.cosmos)
                Positioned.fill(
                  child: CustomPaint(painter: _StarBurstPainter(colors)),
                ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type == AppThemeType.ancien ? '🏆' : '🎉',
                      style: const TextStyle(fontSize: 44),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style:
                          typography.displayMedium.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scoreText,
                      textAlign: TextAlign.center,
                      style: typography.bodyLarge.copyWith(
                        color: isAncien
                            ? const Color(0xFF6B3E1E)
                            : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ThemedButton(
                            label: 'Menu',
                            variant: ThemedButtonVariant.outline,
                            expanded: true,
                            onPressed: onMenu,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ThemedButton(
                            label: 'Rejouer',
                            expanded: true,
                            onPressed: onReplay,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lignes de balayage horizontales pour l'effet hologramme.
class _ScanlinesPainter extends CustomPainter {
  final AppColors colors;

  const _ScanlinesPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 2;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter oldDelegate) => false;
}

/// Rayons d'étoiles partant du centre pour le thème cosmos.
class _StarBurstPainter extends CustomPainter {
  final AppColors colors;

  const _StarBurstPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.28);
    final rng = Random(7);
    final paint = Paint();
    for (var i = 0; i < 24; i++) {
      final angle = i * pi / 12;
      final len = 30 + rng.nextDouble() * 70;
      paint.color = (i % 2 == 0 ? colors.primary : colors.accent)
          .withValues(alpha: 0.10 + rng.nextDouble() * 0.12);
      paint.strokeWidth = 1 + rng.nextDouble();
      canvas.drawLine(
        center + Offset(cos(angle) * 16, sin(angle) * 16),
        center + Offset(cos(angle) * len, sin(angle) * len),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarBurstPainter oldDelegate) => false;
}
