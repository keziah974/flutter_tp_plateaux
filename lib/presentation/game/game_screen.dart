import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../../domain/enums/game_type.dart';
import '../shared/bot_thinking_overlay.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/game_over_dialog.dart';
import '../shared/player_banner.dart';
import 'widgets/checkers_board.dart';
import 'widgets/connect4_board.dart';
import 'widgets/tictactoe_board.dart';

/// Écran de jeu en mode MOCK : bandeaux joueurs, plateau au centre,
/// overlay IA et dialog de fin de partie simulables.
class GameScreen extends StatefulWidget {
  final String gameType;

  const GameScreen({super.key, required this.gameType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // State mock — remplacé par le GameBloc au branchement.
  bool isBotThinking = false;
  String currentPlayer = 'Joueur 1';
  int scoreJ1 = 0;
  int scoreJ2 = 0;

  GameType get _game => GameType.values.firstWhere(
        (g) => g.name == widget.gameType,
        orElse: () => GameType.ticTacToe,
      );

  void _confirmQuit() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abandonner ?'),
        content: const Text('La partie en cours sera perdue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Continuer la partie'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/home');
            },
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }

  void _simulateGameOver() {
    setState(() => scoreJ1++);
    GameOverDialog.show(
      context,
      title: 'Joueur 1 a gagné !',
      scoreText: 'Score final : $scoreJ1 - $scoreJ2',
      onReplay: () => Navigator.of(context, rootNavigator: true).pop(),
      onMenu: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.go('/home');
      },
    );
  }

  Widget _buildBoard() {
    switch (_game) {
      case GameType.ticTacToe:
        return TicTacToeBoard(
          onCellTap: (_, _) => setState(() {
            currentPlayer =
                currentPlayer == 'Joueur 1' ? 'Joueur 2' : 'Joueur 1';
          }),
        );
      case GameType.connect4:
        return Connect4Board(
          onColumnTap: (_) => setState(() {
            currentPlayer =
                currentPlayer == 'Joueur 1' ? 'Joueur 2' : 'Joueur 1';
          }),
        );
      case GameType.checkers:
        return const CheckersBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(_game.label),
        leading: BackButton(onPressed: _confirmQuit),
        actions: [
          IconButton(
            tooltip: 'Abandonner',
            icon: const Icon(Icons.flag_outlined),
            onPressed: _confirmQuit,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PlayerBanner(
                  pseudo: 'Joueur 1',
                  avatarEmoji: '🎮',
                  sessionScore: '$scoreJ1',
                  isActive: currentPlayer == 'Joueur 1',
                  pieceColor: colors.piece1,
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildBoard(),
                        if (isBotThinking) const BotThinkingOverlay(),
                      ],
                    ),
                  ),
                ),
                PlayerBanner(
                  pseudo: 'Joueur 2',
                  avatarEmoji: '🤖',
                  sessionScore: '$scoreJ2',
                  isActive: currentPlayer == 'Joueur 2',
                  pieceColor: colors.piece2,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemedButton(
                        label: 'Simuler GameOver',
                        variant: ThemedButtonVariant.outline,
                        onPressed: _simulateGameOver,
                      ),
                      const SizedBox(width: 12),
                      ThemedButton(
                        label: isBotThinking ? 'Stop IA' : 'Simuler IA',
                        variant: ThemedButtonVariant.outline,
                        onPressed: () => setState(() {
                          isBotThinking = !isBotThinking;
                          currentPlayer =
                              isBotThinking ? 'Joueur 2' : 'Joueur 1';
                        }),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
