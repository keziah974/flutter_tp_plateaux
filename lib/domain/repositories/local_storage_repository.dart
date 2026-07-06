import '../enums/difficulty.dart';
import '../enums/game_type.dart';

abstract class LocalStorageRepository {
  Future<bool> getTheme();
  Future<void> setTheme(bool isDark);

  Future<Difficulty?> getDifficulty(GameType gameType);
  Future<void> setDifficulty(GameType gameType, Difficulty difficulty);

  Future<GameType?> getLastGame();
  Future<void> setLastGame(GameType gameType);
}
