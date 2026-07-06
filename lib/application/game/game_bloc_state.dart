import 'package:equatable/equatable.dart';

import '../../domain/entities/game_state.dart' as domain;
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/player.dart';

abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameLoading extends GameBlocState {
  const GameLoading();
}

class GameRunning extends GameBlocState {
  final domain.GameState state;
  final Player currentPlayer;
  final GameMode mode;
  final Difficulty? difficulty;
  final Player humanSide;

  const GameRunning({
    required this.state,
    required this.currentPlayer,
    required this.mode,
    required this.humanSide,
    this.difficulty,
  });

  GameRunning copyWith({
    domain.GameState? state,
    Player? currentPlayer,
  }) {
    return GameRunning(
      state: state ?? this.state,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      mode: mode,
      difficulty: difficulty,
      humanSide: humanSide,
    );
  }

  @override
  List<Object?> get props =>
      [state, currentPlayer, mode, difficulty, humanSide];
}

class BotThinking extends GameRunning {
  const BotThinking({
    required super.state,
    required super.currentPlayer,
    required super.mode,
    required super.humanSide,
    super.difficulty,
  });
}

class GameOver extends GameBlocState {
  final domain.GameState state;
  final Player? winner;
  final bool isDraw;
  final Player humanSide;

  const GameOver({
    required this.state,
    required this.winner,
    required this.isDraw,
    required this.humanSide,
  });

  @override
  List<Object?> get props => [state, winner, isDraw, humanSide];
}
