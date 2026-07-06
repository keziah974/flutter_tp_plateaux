import 'package:equatable/equatable.dart';

import '../enums/game_status.dart';
import '../enums/game_type.dart';
import '../enums/player.dart';
import 'move.dart';

/// Cell encoding shared by all engines:
/// 0 = empty, 1 = player one piece, 2 = player two piece,
/// 3 = player one king (checkers only), 4 = player two king (checkers only).
class GameState extends Equatable {
  final GameType gameType;
  final List<List<int>> board;
  final Player currentPlayer;
  final GameStatus status;
  final Player? winner;
  final List<Move> history;

  /// When a multi-capture (rafle) is in progress in Checkers, this holds
  /// the position of the piece that must keep capturing.
  final List<int>? mustContinueFrom;

  const GameState({
    required this.gameType,
    required this.board,
    required this.currentPlayer,
    this.status = GameStatus.inProgress,
    this.winner,
    this.history = const [],
    this.mustContinueFrom,
  });

  int get rows => board.length;
  int get cols => board.isEmpty ? 0 : board.first.length;

  GameState copyWith({
    List<List<int>>? board,
    Player? currentPlayer,
    GameStatus? status,
    Player? winner,
    List<Move>? history,
    List<int>? mustContinueFrom,
    bool clearMustContinue = false,
  }) {
    return GameState(
      gameType: gameType,
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      history: history ?? this.history,
      mustContinueFrom:
          clearMustContinue ? null : (mustContinueFrom ?? this.mustContinueFrom),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameType': gameType.name,
      'board': board,
      'currentPlayer': currentPlayer.name,
      'status': status.name,
      'winner': winner?.name,
      'history': history.map((m) => m.toMap()).toList(),
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      gameType: GameType.values.byName(map['gameType'] as String),
      board: (map['board'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).cast<int>())
          .toList(),
      currentPlayer: Player.values.byName(map['currentPlayer'] as String),
      status: GameStatus.values.byName(map['status'] as String),
      winner: map['winner'] == null
          ? null
          : Player.values.byName(map['winner'] as String),
      history: (map['history'] as List<dynamic>? ?? [])
          .map((m) => Move.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<List<int>> emptyBoard(int rows, int cols) =>
      List.generate(rows, (_) => List.filled(cols, 0));

  @override
  List<Object?> get props => [
        gameType,
        board,
        currentPlayer,
        status,
        winner,
        history,
        mustContinueFrom,
      ];
}
