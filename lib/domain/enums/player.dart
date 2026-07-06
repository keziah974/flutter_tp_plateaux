enum Player { playerOne, playerTwo }

extension PlayerX on Player {
  Player get opponent =>
      this == Player.playerOne ? Player.playerTwo : Player.playerOne;
}
