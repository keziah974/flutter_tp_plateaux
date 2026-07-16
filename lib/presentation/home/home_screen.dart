import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_context.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_model.dart';
import '../../domain/enums/game_type.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

// Données mock — remplacées par AuthBloc/ScoreRepository au branchement.
const _mockUser = {'pseudo': 'Joueur1', 'avatar': '🎮'};
const _mockStats = {'wins': 12, 'losses': 5, 'draws': 3};
const _mockBestScores = {
  GameType.ticTacToe: '8 victoires',
  GameType.connect4: '5 victoires',
  GameType.checkers: '3 victoires',
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openThemeSheet(BuildContext context) {
    final cubit = context.read<ThemeCubit>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: const _ThemeSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            colors.surface.withValues(alpha: 0.8),
                        child: Text(
                          _mockUser['avatar']!,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mockUser['pseudo']!,
                            style: typography.displayMedium,
                          ),
                          Text('Bon retour !',
                              style: typography.bodyMedium),
                        ],
                      ),
                    ),
                    ThemedIconButton(
                      icon: Icons.palette_outlined,
                      tooltip: 'Changer de thème',
                      onPressed: () => _openThemeSheet(context),
                    ),
                    const SizedBox(width: 8),
                    ThemedIconButton(
                      icon: Icons.logout,
                      tooltip: 'Déconnexion',
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatChip(
                      label: 'Victoires',
                      value: '${_mockStats['wins']}',
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Défaites',
                      value: '${_mockStats['losses']}',
                      color: colors.accent,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Nuls',
                      value: '${_mockStats['draws']}',
                      color: colors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Choisis ton jeu', style: typography.displayLarge),
                const SizedBox(height: 16),
                for (final game in GameType.values) ...[
                  _GameCard(game: game),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: typography.displayMedium.copyWith(color: color),
            ),
            Text(label, style: typography.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameType game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return ThemedCard(
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(painter: _GameIconPainter(game, colors)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.label, style: typography.displayMedium),
                const SizedBox(height: 4),
                Text(
                  'Meilleur score : ${_mockBestScores[game]}',
                  style: typography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ThemedButton(
            label: 'Jouer',
            onPressed: () => context.push('/game-select/${game.name}'),
          ),
        ],
      ),
    );
  }
}

/// Mini-icône dessinée pour chaque jeu :
/// grille 3x3, colonnes de cercles, damier.
class _GameIconPainter extends CustomPainter {
  final GameType game;
  final AppColors colors;

  const _GameIconPainter(this.game, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill1 = Paint()..color = colors.piece1;
    final fill2 = Paint()..color = colors.piece2;

    switch (game) {
      case GameType.ticTacToe:
        final third = size.width / 3;
        for (var i = 1; i < 3; i++) {
          canvas.drawLine(
              Offset(third * i, 4), Offset(third * i, size.height - 4), stroke);
          canvas.drawLine(
              Offset(4, third * i), Offset(size.width - 4, third * i), stroke);
        }
      case GameType.connect4:
        final r = size.width / 8;
        for (var col = 0; col < 3; col++) {
          for (var row = 0; row < 3; row++) {
            canvas.drawCircle(
              Offset(
                size.width * (0.2 + col * 0.3),
                size.height * (0.2 + row * 0.3),
              ),
              r,
              (col + row) % 2 == 0 ? fill1 : fill2,
            );
          }
        }
      case GameType.checkers:
        final quarter = size.width / 4;
        for (var col = 0; col < 4; col++) {
          for (var row = 0; row < 4; row++) {
            if ((col + row) % 2 == 1) {
              canvas.drawRect(
                Rect.fromLTWH(
                    col * quarter, row * quarter, quarter, quarter),
                fill2,
              );
            }
          }
        }
        canvas.drawRect(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(_GameIconPainter oldDelegate) =>
      oldDelegate.game != game || oldDelegate.colors != colors;
}

/// Bottom sheet de sélection du thème.
class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet();

  @override
  Widget build(BuildContext context) {
    final current = context.appThemeType;
    final colors = context.appColors;
    final typography = context.appTypography;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choisir un thème', style: typography.displayMedium),
            const SizedBox(height: 16),
            for (final type in AppThemeType.values)
              ListTile(
                onTap: () {
                  context.read<ThemeCubit>().switchTheme(type);
                  Navigator.of(context).pop();
                },
                leading:
                    Text(type.emoji, style: const TextStyle(fontSize: 26)),
                title: Text(type.label, style: typography.bodyLarge),
                trailing: type == current
                    ? Icon(Icons.check_circle, color: colors.primary)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
