import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Card adaptée au thème actif :
/// - Futuriste : glassmorphism (blur + bordure cyan fine)
/// - Ancien : bois (dégradé brun), ombre chaude, bordure dorée
/// - Cosmos : semi-transparente avec micro-étoiles en fond
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final radius = BorderRadius.circular(type == AppThemeType.ancien ? 10 : 18);

    Widget card;
    switch (type) {
      case AppThemeType.futuriste:
        card = ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.35),
                borderRadius: radius,
                border: Border.all(
                  color: borderColor ?? colors.primary.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: child,
            ),
          ),
        );
      case AppThemeType.ancien:
        card = Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.surface, const Color(0xFF31190C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? colors.primary.withValues(alpha: 0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        );
      case AppThemeType.cosmos:
        card = ClipRRect(
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.45),
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? colors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MiniStarsPainter(colors.textPrimary),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        );
    }

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Quelques étoiles statiques discrètes pour le fond des cards Cosmos.
class _MiniStarsPainter extends CustomPainter {
  final Color color;

  const _MiniStarsPainter(this.color);

  static const List<Offset> _positions = [
    Offset(0.08, 0.2),
    Offset(0.25, 0.75),
    Offset(0.42, 0.12),
    Offset(0.58, 0.85),
    Offset(0.71, 0.3),
    Offset(0.85, 0.6),
    Offset(0.93, 0.15),
    Offset(0.15, 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.25);
    for (final p in _positions) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        1.1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniStarsPainter oldDelegate) =>
      oldDelegate.color != color;
}
