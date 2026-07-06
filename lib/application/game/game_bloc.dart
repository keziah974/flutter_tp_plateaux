import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_state.dart' as domain;
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/game_engine.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../../domain/repositories/score_repository.dart';
import '../engines/checkers_engine.dart';
import '../engines/connect4_engine.dart';
import '../engines/tic_tac_toe_engine.dart';
import 'game_bloc_state.dart';
import 'game_event.dart';

class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final ScoreRepository _scoreRepository;
  final LocalStorageRepository _localStorageRepository;
  final String? Function() _currentUserId;
  final Random _random = Random();

  GameEngine? _engine;
  GameType? _gameType;

  GameBloc({
    required this._scoreRepository,
    required this._localStorageRepository,
    required this._currentUserId,
  }) : super(const GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<MovePlayed>(_onMovePlayed);
    on<BotTurnRequested>(_onBotTurnRequested);
    on<GameReset>(_onGameReset);
    on<DifficultyChanged>(_onDifficultyChanged);
  }

  GameEngine _engineFor(GameType type) {
    switch (type) {
      case GameType.ticTacToe:
        return TicTacToeEngine();
      case GameType.connect4:
        return Connect4Engine();
      case GameType.checkers:
        return CheckersEngine();
    }
  }

  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(const GameLoading());

    _gameType = event.gameType;
    _engine = _engineFor(event.gameType);

    await _localStorageRepository.setLastGame(event.gameType);
    if (event.difficulty != null) {
      await _localStorageRepository.setDifficulty(
        event.gameType,
        event.difficulty!,
      );
    }

    final initial = _engine!.initialState();
    emit(GameRunning(
      state: initial,
      currentPlayer: initial.currentPlayer,
      mode: event.mode,
      difficulty: event.difficulty,
      humanSide: event.humanSide,
    ));

    _maybeRequestBotTurn(emit);
  }

  Future<void> _onMovePlayed(
    MovePlayed event,
    Emitter<GameBlocState> emit,
  ) async {
    final current = state;
    if (current is! GameRunning) return;
    if (current.state.status != GameStatus.inProgress) return;

    final next = _engine!.applyMove(current.state, event.move);
    await _emitAfterMove(current, next, emit);
  }

  Future<void> _onBotTurnRequested(
    BotTurnRequested event,
    Emitter<GameBlocState> emit,
  ) async {
    final current = state;
    if (current is! GameRunning) return;
    if (current.mode != GameMode.singlePlayer) return;
    if (current.state.currentPlayer == current.humanSide) return;
    if (current.state.status != GameStatus.inProgress) return;

    emit(BotThinking(
      state: current.state,
      currentPlayer: current.currentPlayer,
      mode: current.mode,
      difficulty: current.difficulty,
      humanSide: current.humanSide,
    ));

    final delayMs = 400 + _random.nextInt(301);
    await Future.delayed(Duration(milliseconds: delayMs));

    final difficulty = current.difficulty ?? Difficulty.medium;
    final move = _engine!.getBotMove(current.state, difficulty);
    final next = _engine!.applyMove(current.state, move);

    await _emitAfterMove(current, next, emit);
  }

  Future<void> _emitAfterMove(
    GameRunning current,
    domain.GameState next,
    Emitter<GameBlocState> emit,
  ) async {
    if (next.status != GameStatus.inProgress) {
      emit(GameOver(
        state: next,
        winner: next.winner,
        isDraw: next.status == GameStatus.draw,
        humanSide: current.humanSide,
      ));
      await _saveScore(current, next);
      return;
    }

    emit(current.copyWith(state: next, currentPlayer: next.currentPlayer));
    _maybeRequestBotTurn(emit);
  }

  void _maybeRequestBotTurn(Emitter<GameBlocState> emit) {
    final current = state;
    if (current is! GameRunning) return;
    if (current.mode == GameMode.singlePlayer &&
        current.state.currentPlayer != current.humanSide &&
        current.state.status == GameStatus.inProgress) {
      add(const BotTurnRequested());
    }
  }

  Future<void> _saveScore(GameRunning current, domain.GameState next) async {
    final userId = _currentUserId();
    if (userId == null || _gameType == null) return;
    if (current.mode != GameMode.singlePlayer) return;

    final humanWon = next.winner == current.humanSide;
    final isDraw = next.status == GameStatus.draw;

    await _scoreRepository.recordResult(
      userId: userId,
      gameType: _gameType!,
      difficulty: current.difficulty,
      won: humanWon,
      draw: isDraw,
    );
  }

  void _onGameReset(GameReset event, Emitter<GameBlocState> emit) {
    final current = state;
    if (_engine == null) return;
    final initial = _engine!.initialState();

    if (current is GameRunning) {
      emit(GameRunning(
        state: initial,
        currentPlayer: initial.currentPlayer,
        mode: current.mode,
        difficulty: current.difficulty,
        humanSide: current.humanSide,
      ));
    } else if (current is GameOver) {
      emit(GameRunning(
        state: initial,
        currentPlayer: initial.currentPlayer,
        mode: GameMode.twoPlayers,
        humanSide: current.humanSide,
      ));
    }
    _maybeRequestBotTurn(emit);
  }

  void _onDifficultyChanged(
    DifficultyChanged event,
    Emitter<GameBlocState> emit,
  ) {
    final current = state;
    if (current is GameRunning) {
      emit(GameRunning(
        state: current.state,
        currentPlayer: current.currentPlayer,
        mode: current.mode,
        difficulty: event.difficulty,
        humanSide: current.humanSide,
      ));
    }
  }
}
