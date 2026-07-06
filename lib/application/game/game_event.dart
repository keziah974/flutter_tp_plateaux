import 'package:equatable/equatable.dart';

import '../../domain/entities/move.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/enums/player.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final GameType gameType;
  final GameMode mode;
  final Difficulty? difficulty;
  final Player humanSide;

  const GameStarted({
    required this.gameType,
    required this.mode,
    required this.humanSide,
    this.difficulty,
  });

  @override
  List<Object?> get props => [gameType, mode, difficulty, humanSide];
}

class MovePlayed extends GameEvent {
  final Move move;
  const MovePlayed(this.move);

  @override
  List<Object?> get props => [move];
}

class BotTurnRequested extends GameEvent {
  const BotTurnRequested();
}

class GameReset extends GameEvent {
  const GameReset();
}

class DifficultyChanged extends GameEvent {
  final Difficulty difficulty;
  const DifficultyChanged(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}
