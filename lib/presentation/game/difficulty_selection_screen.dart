import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../../domain/enums/difficulty.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

/// Choix de la difficulté de l'IA. Card sélectionnée : bordure
/// colorée + scale 1.05, puis bouton « Continuer » vers le choix du camp.
class DifficultySelectionScreen extends StatefulWidget {
  final String gameType;

  const DifficultySelectionScreen({super.key, required this.gameType});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState
    extends State<DifficultySelectionScreen> {
  Difficulty? _selected;

  static const _infos = {
    Difficulty.easy: ('😊', 'Facile', 'Pour débuter'),
    Difficulty.medium: ('🧠', 'Moyen', 'Un vrai défi'),
    Difficulty.hard: ('💀', 'Difficile', 'Bonne chance...'),
  };

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Difficulté'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choisis ta difficulté',
                  textAlign: TextAlign.center,
                  style: typography.displayMedium,
                ),
                const SizedBox(height: 28),
                for (final difficulty in Difficulty.values) ...[
                  _DifficultyCard(
                    emoji: _infos[difficulty]!.$1,
                    title: _infos[difficulty]!.$2,
                    description: _infos[difficulty]!.$3,
                    selected: _selected == difficulty,
                    onTap: () => setState(() => _selected = difficulty),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                ThemedButton(
                  label: 'Continuer',
                  expanded: true,
                  onPressed: _selected == null
                      ? null
                      : () => context.push(
                            '/camp/${widget.gameType}'
                            '?difficulty=${_selected!.name}',
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return AnimatedScale(
      scale: selected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ThemedCard(
        onTap: onTap,
        borderColor: selected ? colors.accent : null,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typography.displayMedium),
                  const SizedBox(height: 2),
                  Text(description, style: typography.bodyMedium),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.check_circle, color: colors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
