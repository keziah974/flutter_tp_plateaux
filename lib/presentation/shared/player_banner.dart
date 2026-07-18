import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/theme_context.dart';
import '../../core/theme/theme_model.dart';

/// Bandeau joueur : avatar + pseudo + score de session.
/// Indicateur de tour actif selon le thème :
/// - Futuriste : bordure néon qui pulse
/// - Ancien : couronne dorée qui apparaît
/// - Cosmos : halo étoilé
/// Inactif : opacité réduite à 0.5.
class PlayerBanner extends StatefulWidget {
  final String pseudo;
  final String avatarEmoji;
  final String sessionScore;
  final bool isActive;
  final Color? pieceColor;

  const PlayerBanner({
    super.key,
    required this.pseudo,
    required this.avatarEmoji,
    required this.sessionScore,
    required this.isActive,
    this.pieceColor,
  });

  @override
  State<PlayerBanner> createState() => _PlayerBannerState();
}

class _PlayerBannerState extends State<PlayerBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final typography = context.appTypography;
    final piece = widget.pieceColor ?? colors.primary;

    return AnimatedOpacity(
      opacity: widget.isActive ? 1 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          Border? border;
          List<BoxShadow> shadows = const [];

          if (widget.isActive) {
            switch (type) {
              case AppThemeType.futuriste:
                border = Border.all(
                  color: piece.withValues(alpha: 0.4 + 0.6 * t),
                  width: 1.6,
                );
                shadows = [
                  BoxShadow(
                    color: piece.withValues(alpha: 0.15 + 0.35 * t),
                    blurRadius: 10 + 12 * t,
                  ),
                ];
              case AppThemeType.ancien:
                border = Border.all(
                  color: colors.primary.withValues(alpha: 0.8),
                  width: 1.4,
                );
              case AppThemeType.cosmos:
                border = Border.all(
                  color: colors.primary.withValues(alpha: 0.5 + 0.4 * t),
                );
                shadows = [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.1 + 0.3 * t),
                    blurRadius: 8 + 14 * t,
                  ),
                ];
            }
          } else {
            border = Border.all(
              color: colors.textSecondary.withValues(alpha: 0.25),
            );
          }

          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: border,
              boxShadow: shadows,
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: piece.withValues(alpha: 0.25),
                  child: Text(
                    widget.avatarEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                // Couronne dorée du thème ancien sur le joueur actif.
                if (type == AppThemeType.ancien)
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: widget.isActive ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Text(
                        '👑',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                // Étoile scintillante du thème cosmos.
                if (type == AppThemeType.cosmos && widget.isActive)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) => Opacity(
                        opacity: 0.4 +
                            0.6 * (0.5 + 0.5 * sin(_pulse.value * pi)),
                        child: const Text('✨',
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.pseudo,
                overflow: TextOverflow.ellipsis,
                style: typography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: piece.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.sessionScore,
                style: typography.labelLarge.copyWith(color: piece),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
