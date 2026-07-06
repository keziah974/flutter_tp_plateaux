import 'package:flutter/material.dart';

/// Placeholder — UI implemented separately by the front-end dev.
class GameScreen extends StatelessWidget {
  final String gameType;
  const GameScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Game screen ($gameType)')),
    );
  }
}
