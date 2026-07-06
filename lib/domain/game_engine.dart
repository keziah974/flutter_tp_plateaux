import 'entities/game_state.dart';
import 'entities/move.dart';
import 'enums/difficulty.dart';
import 'enums/player.dart';

abstract class GameEngine {
  GameState initialState();
  List<Move> getValidMoves(GameState state);
  GameState applyMove(GameState state, Move move);
  Player? getWinner(GameState state);
  bool isDraw(GameState state);
  Move getBotMove(GameState state, Difficulty difficulty);
}
