/// Les trois univers visuels de l'application.
enum AppThemeType { futuriste, ancien, cosmos }

extension AppThemeTypeX on AppThemeType {
  String get label {
    switch (this) {
      case AppThemeType.futuriste:
        return 'NéoGrid';
      case AppThemeType.ancien:
        return 'Bois & Pierre';
      case AppThemeType.cosmos:
        return 'Cosmos';
    }
  }

  String get emoji {
    switch (this) {
      case AppThemeType.futuriste:
        return '⚡';
      case AppThemeType.ancien:
        return '🏛️';
      case AppThemeType.cosmos:
        return '🪐';
    }
  }
}
