import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Background plein écran adapté au thème :
/// - Futuriste : grille de points animée
/// - Ancien : dégradé brun + vignette
/// - Cosmos : 100 étoiles qui scintillent + nébuleuses
class ThemedBackground extends StatefulWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  State<ThemedBackground> createState() => _ThemedBackgroundState();
}

class _ThemedBackgroundState extends State<ThemedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: colors.background),
        ),
        if (type == AppThemeType.ancien)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.5),
                radius: 1.4,
                colors: [Color(0xFF3E2418), Color(0xFF2C1810), Color(0xFF1A0D07)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          )
        else
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: type == AppThemeType.futuriste
                  ? _DotGridPainter(colors, _controller.value)
                  : _StarFieldPainter(colors, _controller.value),
            ),
          ),
        widget.child,
      ],
    );
  }
}

/// Grille de points qui « respire » pour le thème futuriste.
class _DotGridPainter extends CustomPainter {
  final AppColors colors;
  final double t;

  const _DotGridPainter(this.colors, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 36.0;
    final wave = sin(t * 2 * pi);
    final paint = Paint();
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        final phase = (x + y) / 250;
        final alpha = 0.06 + 0.06 * (0.5 + 0.5 * sin(phase + wave * pi));
        paint.color = colors.primary.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.t != t;
}

/// Champ de 100 étoiles scintillantes + nébuleuses pour le thème cosmos.
class _StarFieldPainter extends CustomPainter {
  final AppColors colors;
  final double t;

  _StarFieldPainter(this.colors, this.t);

  static final List<_Star> _stars = _generate();

  static List<_Star> _generate() {
    final rng = Random(42);
    return List.generate(100, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 0.5 + rng.nextDouble() * 1.4,
        phase: rng.nextDouble() * 2 * pi,
        speed: 0.5 + rng.nextDouble() * 1.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Nébuleuses en dégradés radiaux.
    final nebula1 = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.secondary.withValues(alpha: 0.20),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.25),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawRect(Offset.zero & size, nebula1);

    final nebula2 = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.accent.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.75),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawRect(Offset.zero & size, nebula2);

    // Étoiles scintillantes.
    final paint = Paint();
    for (final star in _stars) {
      final twinkle =
          0.5 + 0.5 * sin(star.phase + t * 2 * pi * star.speed);
      paint.color =
          Colors.white.withValues(alpha: 0.25 + 0.6 * twinkle);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => oldDelegate.t != t;
}

class _Star {
  final double x, y, radius, phase, speed;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}
