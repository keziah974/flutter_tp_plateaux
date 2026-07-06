import 'package:flutter/material.dart';

/// Placeholder — UI implemented separately by the front-end dev.
class DifficultySelectionScreen extends StatelessWidget {
  final String gameType;
  const DifficultySelectionScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Difficulty selection screen ($gameType)')),
    );
  }
}
