import 'dart:math';

import '../../domain/entities/game_state.dart';
import '../../domain/entities/move.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/enums/player.dart';
import '../../domain/game_engine.dart';

class Connect4Engine implements GameEngine {
  static const rows = 6;
  static const cols = 7;
  final _random = Random();

  @override
  GameState initialState() {
    return GameState(
      gameType: GameType.connect4,
      board: GameState.emptyBoard(rows, cols),
      currentPlayer: Player.playerOne,
    );
  }

  int _codeFor(Player player) => player == Player.playerOne ? 1 : 2;

  int? _landingRow(List<List<int>> board, int col) {
    for (var r = rows - 1; r >= 0; r--) {
      if (board[r][col] == 0) return r;
    }
    return null;
  }

  @override
  List<Move> getValidMoves(GameState state) {
    if (state.status != GameStatus.inProgress) return [];
    final moves = <Move>[];
    for (var c = 0; c < cols; c++) {
      final row = _landingRow(state.board, c);
      if (row != null) {
        moves.add(Move(toRow: row, toCol: c));
      }
    }
    return moves;
  }

  @override
  GameState applyMove(GameState state, Move move) {
    final board = state.board.map((row) => [...row]).toList();
    final landingRow = _landingRow(board, move.toCol);
    if (landingRow == null) {
      throw StateError('Column ${move.toCol} is full');
    }
    board[landingRow][move.toCol] = _codeFor(state.currentPlayer);

    final actualMove = Move(toRow: landingRow, toCol: move.toCol);
    final tentative = state.copyWith(
      board: board,
      currentPlayer: state.currentPlayer.opponent,
      history: [...state.history, actualMove],
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

  /// Returns the 4 winning cell coordinates, or null if no winner yet.
  List<List<int>>? winningLine(GameState state) {
    final board = state.board;
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final value = board[r][c];
        if (value == 0) continue;
        for (final dir in directions) {
          final line = <List<int>>[
            [r, c]
          ];
          var rr = r, cc = c;
          for (var i = 1; i < 4; i++) {
            rr += dir[0];
            cc += dir[1];
            if (rr < 0 || rr >= rows || cc < 0 || cc >= cols) break;
            if (board[rr][cc] != value) break;
            line.add([rr, cc]);
          }
          if (line.length == 4) return line;
        }
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
    return state.board[0].every((cell) => cell != 0);
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

    final depth = difficulty == Difficulty.medium ? 3 : 6;
    final bot = state.currentPlayer;
    Move? bestMove;
    var bestScore = -1 << 30;
    var alpha = -1 << 30;
    const beta = 1 << 30;
    for (final move in moves) {
      final next = applyMove(state, move);
      final score = _minimax(next, bot, depth - 1, alpha, beta, false);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
      alpha = max(alpha, bestScore);
    }
    return bestMove!;
  }

  int _minimax(
    GameState state,
    Player bot,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    final winner = getWinner(state);
    if (winner != null) {
      return winner == bot ? 100000 + depth : -100000 - depth;
    }
    if (isDraw(state) || depth == 0) {
      return _evaluate(state, bot);
    }

    final moves = getValidMoves(state);
    if (maximizing) {
      var best = -1 << 30;
      for (final move in moves) {
        final next = applyMove(state, move);
        final score = _minimax(next, bot, depth - 1, alpha, beta, false);
        best = max(best, score);
        alpha = max(alpha, best);
        if (alpha >= beta) break;
      }
      return best;
    } else {
      var best = 1 << 30;
      for (final move in moves) {
        final next = applyMove(state, move);
        final score = _minimax(next, bot, depth - 1, alpha, beta, true);
        best = min(best, score);
        beta = min(beta, best);
        if (alpha >= beta) break;
      }
      return best;
    }
  }

  int _evaluate(GameState state, Player bot) {
    var score = 0;
    final botCode = _codeFor(bot);
    final oppCode = _codeFor(bot.opponent);
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        for (final dir in directions) {
          final window = <int>[];
          for (var i = 0; i < 4; i++) {
            final rr = r + dir[0] * i;
            final cc = c + dir[1] * i;
            if (rr < 0 || rr >= rows || cc < 0 || cc >= cols) break;
            window.add(state.board[rr][cc]);
          }
          if (window.length == 4) {
            score += _scoreWindow(window, botCode, oppCode);
          }
        }
      }
    }
    return score;
  }

  int _scoreWindow(List<int> window, int botCode, int oppCode) {
    final botCount = window.where((v) => v == botCode).length;
    final oppCount = window.where((v) => v == oppCode).length;
    final emptyCount = window.where((v) => v == 0).length;

    if (botCount > 0 && oppCount > 0) return 0;
    if (botCount == 4) return 1000;
    if (botCount == 3 && emptyCount == 1) return 50;
    if (botCount == 2 && emptyCount == 2) return 10;
    if (oppCount == 3 && emptyCount == 1) return -80;
    if (oppCount == 2 && emptyCount == 2) return -8;
    return 0;
  }
}
