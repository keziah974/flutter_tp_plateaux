import 'package:flutter/material.dart';

class PlayerBanner extends StatelessWidget {
  final String pseudo;
  final String avatarEmoji;
  final int sessionScore;
  final bool isActive;
  final Color accentColor;

  const PlayerBanner({
    super.key,
    required this.pseudo,
    required this.avatarEmoji,
    required this.sessionScore,
    required this.isActive,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? accentColor : Colors.transparent,
          width: 3,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(avatarEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pseudo,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Score : $sessionScore',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(Icons.play_circle_fill, color: accentColor, size: 22),
        ],
      ),
    );
  }
}
