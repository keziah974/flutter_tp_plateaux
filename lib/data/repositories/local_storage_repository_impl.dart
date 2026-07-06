import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../datasources/local_storage_datasource.dart';

class LocalStorageRepositoryImpl implements LocalStorageRepository {
  final LocalStorageDatasource _datasource;

  LocalStorageRepositoryImpl({required this._datasource});

  @override
  Future<bool> getTheme() => _datasource.getDarkMode();

  @override
  Future<void> setTheme(bool isDark) => _datasource.setDarkMode(isDark);

  @override
  Future<GameType?> getLastGame() async {
    final name = await _datasource.getLastGamePlayed();
    if (name == null) return null;
    return GameType.values.byName(name);
  }

  @override
  Future<void> setLastGame(GameType gameType) {
    return _datasource.setLastGamePlayed(gameType.name);
  }

  @override
  Future<Difficulty?> getDifficulty(GameType gameType) async {
    final name = await _datasource.getPreferredDifficulty(gameType.name);
    if (name == null) return null;
    return Difficulty.values.byName(name);
  }

  @override
  Future<void> setDifficulty(GameType gameType, Difficulty difficulty) {
    return _datasource.setPreferredDifficulty(gameType.name, difficulty.name);
  }
}
