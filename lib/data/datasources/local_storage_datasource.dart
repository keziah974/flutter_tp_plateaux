import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageDatasource {
  static const _darkModeKey = 'dark_mode';
  static const _lastGameKey = 'last_game_played';
  static const _difficultyPrefix = 'difficulty_';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<String?> getLastGamePlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastGameKey);
  }

  Future<void> setLastGamePlayed(String gameTypeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastGameKey, gameTypeName);
  }

  Future<String?> getPreferredDifficulty(String gameTypeName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_difficultyPrefix$gameTypeName');
  }

  Future<void> setPreferredDifficulty(
    String gameTypeName,
    String difficultyName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_difficultyPrefix$gameTypeName', difficultyName);
  }
}
