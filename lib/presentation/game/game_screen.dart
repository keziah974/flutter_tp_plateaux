import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';
import '../../application/game/game_bloc.dart';
import '../../application/game/game_bloc_state.dart';
import '../../application/game/game_event.dart';
import '../../core/service_locator.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/enums/player.dart';
import '../shared/game_over_dialog.dart';
import '../shared/player_banner.dart';
import 'game_navigation_args.dart';
import 'widgets/checkers_board.dart';
import 'widgets/connect4_board.dart';
import 'widgets/tictactoe_board.dart';

class GameScreen extends StatelessWidget {
  final String gameType;
  const GameScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    final type = GameType.values.byName(gameType);
    final mode = GameNavigationArgs.mode;
    final difficulty = GameNavigationArgs.difficulty;

    return BlocProvider<GameBloc>(
      create: (_) => ServiceLocator.instance.createGameBloc()
        ..add(GameStarted(
          gameType: type,
          mode: mode,
          humanSide: Player.playerOne,
          difficulty: difficulty,
        )),
      child: _GameView(gameType: type),
    );
  }
}

class _GameView extends StatefulWidget {
  final GameType gameType;
  const _GameView({required this.gameType});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  int _p1Wins = 0;
  int _p2Wins = 0;

  String get _p1Pseudo {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.pseudo : 'Joueur 1';
  }

  String get _p1Avatar {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.avatarEmoji : '🎲';
  }

  void _showGameOverDialog(GameOver state) {
    final String title;
    if (state.isDraw) {
      title = 'Match nul !';
    } else {
      final winnerIsP1 = state.winner == Player.playerOne;
      title = winnerIsP1 ? '$_p1Pseudo a gagné !' : 'Joueur 2 a gagné !';
    }
    if (!state.isDraw) {
      if (state.winner == Player.playerOne) {
        _p1Wins++;
      } else {
        _p2Wins++;
      }
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        title: title,
        subtitle: state.isDraw ? 'Personne ne gagne cette fois.' : '',
      ),
    );
  }

  Widget _board(GameBlocState state, bool enabled) {
    if (state is! GameRunning) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (widget.gameType) {
      case GameType.ticTacToe:
        return TicTacToeBoard(
          state: state.state,
          enabled: enabled,
          onMove: (move) => context.read<GameBloc>().add(MovePlayed(move)),
        );
      case GameType.connect4:
        return Connect4Board(
          state: state.state,
          enabled: enabled,
          onMove: (move) => context.read<GameBloc>().add(MovePlayed(move)),
        );
      case GameType.checkers:
        return CheckersBoard(
          state: state.state,
          enabled: enabled,
          onMove: (move) => context.read<GameBloc>().add(MovePlayed(move)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameType.label),
        actions: [
          IconButton(
            tooltip: 'Abandonner',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: BlocConsumer<GameBloc, GameBlocState>(
        listener: (context, state) {
          if (state is GameOver) {
            _showGameOverDialog(state);
          }
        },
        builder: (context, state) {
          final isBotThinking = state is BotThinking;
          final currentPlayer = state is GameRunning
              ? state.currentPlayer
              : (state is GameOver ? null : Player.playerOne);
          final enabled = state is GameRunning &&
              !isBotThinking &&
              (state.mode == GameMode.twoPlayers ||
                  state.currentPlayer == state.humanSide);

          final difficultyLabel = state is GameRunning
              ? _difficultyLabel(state.difficulty)
              : null;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PlayerBanner(
                    pseudo: _p1Pseudo,
                    avatarEmoji: _p1Avatar,
                    sessionScore: _p1Wins,
                    isActive: currentPlayer == Player.playerOne,
                    accentColor: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  if (difficultyLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        difficultyLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _board(state, enabled),
                          if (isBotThinking)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text('Le bot réfléchit…'),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PlayerBanner(
                    pseudo: state is GameRunning &&
                            state.mode == GameMode.singlePlayer
                        ? 'Bot'
                        : 'Joueur 2',
                    avatarEmoji: state is GameRunning &&
                            state.mode == GameMode.singlePlayer
                        ? '🤖'
                        : '🎮',
                    sessionScore: _p2Wins,
                    isActive: currentPlayer == Player.playerTwo,
                    accentColor: Colors.blue,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _difficultyLabel(Difficulty? difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Difficulté : Facile';
      case Difficulty.medium:
        return 'Difficulté : Moyen';
      case Difficulty.hard:
        return 'Difficulté : Difficile';
      case null:
        return '';
    }
  }
}
