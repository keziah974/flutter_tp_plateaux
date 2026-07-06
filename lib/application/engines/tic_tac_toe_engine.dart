import 'dart:math';

import '../../domain/entities/game_state.dart';
import '../../domain/entities/move.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/enums/player.dart';
import '../../domain/game_engine.dart';

class TicTacToeEngine implements GameEngine {
  static const size = 3;
  final _random = Random();

  @override
  GameState initialState() {
    return GameState(
      gameType: GameType.ticTacToe,
      board: GameState.emptyBoard(size, size),
      currentPlayer: Player.playerOne,
    );
  }

  int _codeFor(Player player) => player == Player.playerOne ? 1 : 2;

  @override
  List<Move> getValidMoves(GameState state) {
    if (state.status != GameStatus.inProgress) return [];
    final moves = <Move>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (state.board[r][c] == 0) {
          moves.add(Move(toRow: r, toCol: c));
        }
      }
    }
    return moves;
  }

  @override
  GameState applyMove(GameState state, Move move) {
    final board = state.board.map((row) => [...row]).toList();
    board[move.toRow][move.toCol] = _codeFor(state.currentPlayer);

    final newHistory = [...state.history, move];
    final tentative = state.copyWith(
      board: board,
      currentPlayer: state.currentPlayer.opponent,
      history: newHistory,
    );

    final winner = getWinner(tentative);
    if (winner != null) {
      return tentative.copyWith(status: GameStatus.won, winner: winner);
    }
    if (isDraw(tentative)) {
      return tentative.copyWith(status: GameStatus.draw);
    }
    return tentative;
  }

  static const _lines = [
    [
      [0, 0],
      [0, 1],
      [0, 2]
    ],
    [
      [1, 0],
      [1, 1],
      [1, 2]
    ],
    [
      [2, 0],
      [2, 1],
      [2, 2]
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0]
    ],
    [
      [0, 1],
      [1, 1],
      [2, 1]
    ],
    [
      [0, 2],
      [1, 2],
      [2, 2]
    ],
    [
      [0, 0],
      [1, 1],
      [2, 2]
    ],
    [
      [0, 2],
      [1, 1],
      [2, 0]
    ],
  ];

  /// Returns the winning line's cell coordinates, or null if none.
  List<List<int>>? winningLine(GameState state) {
    for (final line in _lines) {
      final values = line.map((p) => state.board[p[0]][p[1]]).toList();
      if (values[0] != 0 && values[0] == values[1] && values[1] == values[2]) {
        return line;
      }
    }
    return null;
  }

  @override
  Player? getWinner(GameState state) {
    final line = winningLine(state);
    if (line == null) return null;
    final value = state.board[line[0][0]][line[0][1]];
    return value == 1 ? Player.playerOne : Player.playerTwo;
  }

  @override
  bool isDraw(GameState state) {
    if (getWinner(state) != null) return false;
    return state.board.every((row) => row.every((cell) => cell != 0));
  }

  @override
  Move getBotMove(GameState state, Difficulty difficulty) {
    final moves = getValidMoves(state);
    if (moves.isEmpty) {
      throw StateError('No valid moves available');
    }
    if (difficulty == Difficulty.easy) {
      return moves[_random.nextInt(moves.length)];
    }
    if (difficulty == Difficulty.medium) {
      return _blockingMove(state, moves);
    }
    // Hard plays a perfect minimax game for Tic-Tac-Toe.
    final bot = state.currentPlayer;
    Move? bestMove;
    var bestScore = -1 << 30;
    for (final move in moves) {
      final next = applyMove(state, move);
      final score = _minimax(next, bot, 1);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove!;
  }

  /// Medium bot: wins immediately if possible, otherwise blocks the
  /// opponent's winning move, otherwise plays randomly.
  Move _blockingMove(GameState state, List<Move> moves) {
    final bot = state.currentPlayer;

    for (final move in moves) {
      final next = applyMove(state, move);
      if (getWinner(next) == bot) return move;
    }

    final opponentTurn = state.copyWith(currentPlayer: bot.opponent);
    for (final move in moves) {
      final next = applyMove(opponentTurn, move);
      if (getWinner(next) == bot.opponent) return move;
    }

    return moves[_random.nextInt(moves.length)];
  }

  int _minimax(GameState state, Player bot, int depth) {
    final winner = getWinner(state);
    if (winner != null) {
      return winner == bot ? 10 - depth : depth - 10;
    }
    if (isDraw(state)) return 0;

    final moves = getValidMoves(state);
    final maximizing = state.currentPlayer == bot;
    var best = maximizing ? -1 << 30 : 1 << 30;
    for (final move in moves) {
      final next = applyMove(state, move);
      final score = _minimax(next, bot, depth + 1);
      if (maximizing) {
        best = max(best, score);
      } else {
        best = min(best, score);
      }
    }
    return best;
  }
}
