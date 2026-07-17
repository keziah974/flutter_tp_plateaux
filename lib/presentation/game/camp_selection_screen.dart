import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

/// Choix du camp : Joueur 1 (commence en premier) ou Joueur 2.
class CampSelectionScreen extends StatefulWidget {
  final String gameType;
  final String difficulty;

  const CampSelectionScreen({
    super.key,
    required this.gameType,
    required this.difficulty,
  });

  @override
  State<CampSelectionScreen> createState() => _CampSelectionScreenState();
}

class _CampSelectionScreenState extends State<CampSelectionScreen> {
  int? _selectedCamp;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ton camp'),
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
                  'Choisir votre camp',
                  textAlign: TextAlign.center,
                  style: typography.displayMedium,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _CampCard(
                        title: 'Joueur 1',
                        subtitle: 'Commence en premier',
                        pieceColor: colors.piece1,
                        selected: _selectedCamp == 1,
                        onTap: () => setState(() => _selectedCamp = 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CampCard(
                        title: 'Joueur 2',
                        subtitle: 'Commence en second',
                        pieceColor: colors.piece2,
                        selected: _selectedCamp == 2,
                        onTap: () => setState(() => _selectedCamp = 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ThemedButton(
                  label: 'Lancer la partie',
                  expanded: true,
                  onPressed: _selectedCamp == null
                      ? null
                      : () => context.push(
                            '/game/${widget.gameType}'
                            '?mode=1p'
                            '&difficulty=${widget.difficulty}'
                            '&camp=$_selectedCamp',
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

class _CampCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color pieceColor;
  final bool selected;
  final VoidCallback onTap;

  const _CampCard({
    required this.title,
    required this.subtitle,
    required this.pieceColor,
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pieceColor,
                boxShadow: [
                  BoxShadow(
                    color: pieceColor.withValues(
                      alpha: selected ? 0.7 : 0.3,
                    ),
                    blurRadius: selected ? 22 : 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typography.displayMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: typography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
