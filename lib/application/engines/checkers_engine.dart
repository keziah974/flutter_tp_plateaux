import 'dart:math';

import '../../domain/entities/game_state.dart';
import '../../domain/entities/move.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/enums/player.dart';
import '../../domain/game_engine.dart';

/// French draughts (jeu de dames) on a 10x10 board.
///
/// Cell codes: 0 empty, 1 = player one man, 2 = player two man,
/// 3 = player one king, 4 = player two king.
/// Player one starts on rows 0-3 and advances toward row 9.
/// Player two starts on rows 6-9 and advances toward row 0.
/// Captures are mandatory and multi-captures (rafles) must be played to
/// their end; when several capture sequences exist, only the sequence(s)
/// capturing the greatest number of pieces are legal (French majority rule).
class CheckersEngine implements GameEngine {
  static const size = 10;
  final _random = Random();

  @override
  GameState initialState() {
    final board = GameState.emptyBoard(size, size);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < size; c++) {
        if ((r + c) % 2 == 1) board[r][c] = 1;
      }
    }
    for (var r = 6; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if ((r + c) % 2 == 1) board[r][c] = 2;
      }
    }
    return GameState(
      gameType: GameType.checkers,
      board: board,
      currentPlayer: Player.playerOne,
    );
  }

  bool _isKing(int code) => code == 3 || code == 4;
  bool _isEmpty(int code) => code == 0;
  Player? _ownerOf(int code) {
    if (code == 1 || code == 3) return Player.playerOne;
    if (code == 2 || code == 4) return Player.playerTwo;
    return null;
  }

  bool _inBounds(int r, int c) => r >= 0 && r < size && c >= 0 && c < size;

  static const _allDirs = [
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1],
  ];

  @override
  List<Move> getValidMoves(GameState state) {
    if (state.status != GameStatus.inProgress) return [];

    final player = state.currentPlayer;
    final board = state.board;

    // If a rafle is already in progress, only that piece may move.
    if (state.mustContinueFrom != null) {
      final r = state.mustContinueFrom![0];
      final c = state.mustContinueFrom![1];
      final sequences = _captureSequencesFrom(board, r, c, player);
      return _keepLongest(sequences);
    }

    final allCaptures = <Move>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (_ownerOf(board[r][c]) != player) continue;
        allCaptures.addAll(_captureSequencesFrom(board, r, c, player));
      }
    }
    if (allCaptures.isNotEmpty) {
      return _keepLongest(allCaptures);
    }

    final simpleMoves = <Move>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (_ownerOf(board[r][c]) != player) continue;
        simpleMoves.addAll(_simpleMovesFrom(board, r, c, player));
      }
    }
    return simpleMoves;
  }

  List<Move> _keepLongest(List<Move> captures) {
    final maxCaptures =
        captures.map((m) => m.capturedPositions.length).reduce(max);
    return captures
        .where((m) => m.capturedPositions.length == maxCaptures)
        .toList();
  }

  List<Move> _simpleMovesFrom(
    List<List<int>> board,
    int r,
    int c,
    Player player,
  ) {
    final code = board[r][c];
    final king = _isKing(code);
    final moves = <Move>[];
    final dirs = king
        ? _allDirs
        : (player == Player.playerOne
            ? [
                [1, 1],
                [1, -1]
              ]
            : [
                [-1, 1],
                [-1, -1]
              ]);

    for (final dir in dirs) {
      if (king) {
        var rr = r + dir[0];
        var cc = c + dir[1];
        while (_inBounds(rr, cc) && _isEmpty(board[rr][cc])) {
          moves.add(Move(fromRow: r, fromCol: c, toRow: rr, toCol: cc));
          rr += dir[0];
          cc += dir[1];
        }
      } else {
        final rr = r + dir[0];
        final cc = c + dir[1];
        if (_inBounds(rr, cc) && _isEmpty(board[rr][cc])) {
          final promotes = player == Player.playerOne ? rr == size - 1 : rr == 0;
          moves.add(Move(
            fromRow: r,
            fromCol: c,
            toRow: rr,
            toCol: cc,
            isPromotion: promotes,
          ));
        }
      }
    }
    return moves;
  }

  /// Generates all maximal capture sequences starting at (r,c), as flat
  /// Move objects with the full chain in capturedPositions.
  List<Move> _captureSequencesFrom(
    List<List<int>> board,
    int r,
    int c,
    Player player,
  ) {
    final results = <Move>[];
    final code = board[r][c];
    final king = _isKing(code);

    void explore(
      List<List<int>> currentBoard,
      int curR,
      int curC,
      List<List<int>> captured,
    ) {
      var foundFurther = false;

      if (king) {
        for (final dir in _allDirs) {
          var rr = curR + dir[0];
          var cc = curC + dir[1];
          // Skip over empty squares to find a potential enemy piece.
          while (_inBounds(rr, cc) && _isEmpty(currentBoard[rr][cc])) {
            rr += dir[0];
            cc += dir[1];
          }
          if (!_inBounds(rr, cc)) continue;
          final enemy = _ownerOf(currentBoard[rr][cc]);
          if (enemy == null || enemy == player) continue;
          if (captured.any((p) => p[0] == rr && p[1] == cc)) continue;
          var landR = rr + dir[0];
          var landC = cc + dir[1];
          while (_inBounds(landR, landC) && _isEmpty(currentBoard[landR][landC])) {
            foundFurther = true;
            final nextBoard = currentBoard.map((row) => [...row]).toList();
            nextBoard[curR][curC] = 0;
            nextBoard[landR][landC] = code;
            explore(nextBoard, landR, landC, [
              ...captured,
              [rr, cc]
            ]);
            landR += dir[0];
            landC += dir[1];
          }
        }
      } else {
        for (final dir in _allDirs) {
          final midR = curR + dir[0];
          final midC = curC + dir[1];
          final landR = curR + dir[0] * 2;
          final landC = curC + dir[1] * 2;
          if (!_inBounds(landR, landC)) continue;
          if (!_isEmpty(currentBoard[landR][landC])) continue;
          final enemy = _ownerOf(currentBoard[midR][midC]);
          if (enemy == null || enemy == player) continue;
          if (captured.any((p) => p[0] == midR && p[1] == midC)) continue;

          foundFurther = true;
          final nextBoard = currentBoard.map((row) => [...row]).toList();
          nextBoard[curR][curC] = 0;
          nextBoard[landR][landC] = code;
          explore(nextBoard, landR, landC, [
            ...captured,
            [midR, midC]
          ]);
        }
      }

      if (!foundFurther && captured.isNotEmpty) {
        final promotes = !king &&
            (player == Player.playerOne ? curR == size - 1 : curR == 0);
        results.add(Move(
          fromRow: r,
          fromCol: c,
          toRow: curR,
          toCol: curC,
          capturedPositions: captured,
          isPromotion: promotes,
        ));
      }
    }

    explore(board, r, c, []);
    return results;
  }

  @override
  GameState applyMove(GameState state, Move move) {
    final board = state.board.map((row) => [...row]).toList();
    final fromR = move.fromRow!;
    final fromC = move.fromCol!;
    var code = board[fromR][fromC];

    board[fromR][fromC] = 0;
    for (final captured in move.capturedPositions) {
      board[captured[0]][captured[1]] = 0;
    }
    if (move.isPromotion) {
      code = code == 1 ? 3 : 4;
    }
    board[move.toRow][move.toCol] = code;

    final newHistory = [...state.history, move];

    // Rafle continuation: if this was a capture, check whether the same
    // piece has further mandatory captures from its new position.
    if (move.isCapture) {
      final further =
          _captureSequencesFrom(board, move.toRow, move.toCol, state.currentPlayer);
      if (further.isNotEmpty) {
        final tentative = state.copyWith(
          board: board,
          history: newHistory,
          mustContinueFrom: [move.toRow, move.toCol],
        );
        return tentative;
      }
    }

    final tentative = state.copyWith(
      board: board,
      currentPlayer: state.currentPlayer.opponent,
      history: newHistory,
      clearMustContinue: true,
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

  @override
  Player? getWinner(GameState state) {
    final board = state.board;
    var p1Pieces = 0, p2Pieces = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == 1 || cell == 3) p1Pieces++;
        if (cell == 2 || cell == 4) p2Pieces++;
      }
    }
    if (p1Pieces == 0) return Player.playerTwo;
    if (p2Pieces == 0) return Player.playerOne;

    // A player with no legal moves loses.
    final opponentState = state.copyWith(
      currentPlayer: state.currentPlayer,
      clearMustContinue: true,
    );
    if (getValidMoves(opponentState).isEmpty) {
      return state.currentPlayer.opponent;
    }
    return null;
  }

  @override
  bool isDraw(GameState state) => false;

  @override
  Move getBotMove(GameState state, Difficulty difficulty) {
    final moves = getValidMoves(state);
    if (moves.isEmpty) {
      throw StateError('No valid moves available');
    }
    if (difficulty == Difficulty.easy) {
      return moves[_random.nextInt(moves.length)];
    }

    final depth = difficulty == Difficulty.medium ? 2 : 4;
    final bot = state.currentPlayer;
    Move? bestMove;
    var bestScore = -1 << 30;
    var alpha = -1 << 30;
    const beta = 1 << 30;
    for (final move in moves) {
      final next = _applyFullTurn(state, move, bot);
      final score = _minimax(next, bot, depth - 1, alpha, beta, next.currentPlayer == bot);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
      alpha = max(alpha, bestScore);
    }
    return bestMove!;
  }

  /// Applies a move and, if a rafle continuation is forced, keeps playing
  /// the best-evaluated continuation automatically for search purposes.
  GameState _applyFullTurn(GameState state, Move move, Player bot) {
    var current = applyMove(state, move);
    while (current.mustContinueFrom != null &&
        current.status == GameStatus.inProgress) {
      final continuations = getValidMoves(current);
      if (continuations.isEmpty) break;
      // For search purposes just take the first continuation branch; the
      // recursive minimax over full sequences would be prohibitively slow,
      // and mandatory-rafle rules mean the branching here is limited.
      current = applyMove(current, continuations.first);
    }
    return current;
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
    if (depth == 0) {
      return _evaluate(state, bot);
    }
    final moves = getValidMoves(state);
    if (moves.isEmpty) {
      return maximizing ? -100000 : 100000;
    }

    if (maximizing) {
      var best = -1 << 30;
      for (final move in moves) {
        final next = _applyFullTurn(state, move, bot);
        final score =
            _minimax(next, bot, depth - 1, alpha, beta, next.currentPlayer == bot);
        best = max(best, score);
        alpha = max(alpha, best);
        if (alpha >= beta) break;
      }
      return best;
    } else {
      var best = 1 << 30;
      for (final move in moves) {
        final next = _applyFullTurn(state, move, bot);
        final score =
            _minimax(next, bot, depth - 1, alpha, beta, next.currentPlayer == bot);
        best = min(best, score);
        beta = min(beta, best);
        if (alpha >= beta) break;
      }
      return best;
    }
  }

  int _evaluate(GameState state, Player bot) {
    var score = 0;
    for (final row in state.board) {
      for (final cell in row) {
        final owner = _ownerOf(cell);
        if (owner == null) continue;
        final value = _isKing(cell) ? 3 : 1;
        score += owner == bot ? value : -value;
      }
    }
    return score;
  }
}
