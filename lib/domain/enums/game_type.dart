enum GameType { ticTacToe, connect4, checkers }

extension GameTypeX on GameType {
  String get label {
    switch (this) {
      case GameType.ticTacToe:
        return 'Morpion';
      case GameType.connect4:
        return 'Puissance 4';
      case GameType.checkers:
        return 'Dames';
    }
  }
}
