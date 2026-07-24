import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_card.dart';

// Données mock — remplacées par le ScoreRepository au branchement.
const _mockScores = [
  {'game': 'Morpion', 'difficulty': 'Facile', 'wins': 8, 'losses': 2},
  {'game': 'Morpion', 'difficulty': 'Difficile', 'wins': 1, 'losses': 9},
  {'game': 'Puissance 4', 'difficulty': 'Moyen', 'wins': 5, 'losses': 4},
  {'game': 'Dames', 'difficulty': 'Facile', 'wins': 3, 'losses': 3},
];
const _mockTotals = {'wins': 17, 'losses': 18, 'draws': 3};

/// Statistiques (mock) : total global + détail par jeu × difficulté
/// avec barre de progression victoires/défaites.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ThemedCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TotalColumn(
                      label: 'Victoires',
                      value: '${_mockTotals['wins']}',
                      color: colors.primary,
                    ),
                    _TotalColumn(
                      label: 'Défaites',
                      value: '${_mockTotals['losses']}',
                      color: colors.accent,
                    ),
                    _TotalColumn(
                      label: 'Nuls',
                      value: '${_mockTotals['draws']}',
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Détail par jeu', style: typography.displayMedium),
              const SizedBox(height: 12),
              for (final score in _mockScores) ...[
                _ScoreCard(
                  game: score['game']! as String,
                  difficulty: score['difficulty']! as String,
                  wins: score['wins']! as int,
                  losses: score['losses']! as int,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TotalColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;
    return Column(
      children: [
        Text(
          value,
          style: typography.displayLarge.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: typography.bodyMedium),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String game;
  final String difficulty;
  final int wins;
  final int losses;

  const _ScoreCard({
    required this.game,
    required this.difficulty,
    required this.wins,
    required this.losses,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final total = wins + losses;
    final ratio = total == 0 ? 0.0 : wins / total;

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(game, style: typography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(difficulty, style: typography.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: colors.primary,
              backgroundColor: colors.accent.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$wins victoires · $losses défaites '
            '(${(ratio * 100).round()} %)',
            style: typography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
