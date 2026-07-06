import 'package:flutter/material.dart';

/// Placeholder — UI implemented separately by the front-end dev.
class ModeSelectionScreen extends StatelessWidget {
  final String gameType;
  const ModeSelectionScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Mode selection screen ($gameType)')),
    );
  }
}
