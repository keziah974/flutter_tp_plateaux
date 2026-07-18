import 'package:flutter/material.dart';

import '../../core/theme/theme_context.dart';

/// Overlay semi-transparent affiché sur le plateau pendant que
/// l'IA réfléchit : texte + 3 points qui clignotent en décalé.
class BotThinkingOverlay extends StatefulWidget {
  const BotThinkingOverlay({super.key});

  @override
  State<BotThinkingOverlay> createState() => _BotThinkingOverlayState();
}

class _BotThinkingOverlayState extends State<BotThinkingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: colors.background.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🤖', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text("L'IA réfléchit", style: typography.bodyLarge),
                const SizedBox(width: 6),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final phase =
                            (_controller.value * 3 - i).clamp(0.0, 1.0);
                        final visible = phase > 0 && phase < 1;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Opacity(
                            opacity: visible ? 1 : 0.25,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
