import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_status.dart';

/// Ephemeral navigation payload set by ModeSelectionScreen /
/// DifficultySelectionScreen right before navigating to `/game/:gameType`,
/// and consumed once by GameScreen. Exists purely because the app's
/// go_router configuration (core/router, out of scope for the front-end
/// work) only threads the `gameType` path segment through to GameScreen.
class GameNavigationArgs {
  GameNavigationArgs._();

  static GameMode mode = GameMode.twoPlayers;
  static Difficulty? difficulty;
}
