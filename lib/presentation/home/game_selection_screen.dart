import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/enums/game_type.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un jeu')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: GameType.values.map((gameType) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              title: Text(gameType.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/mode-select/${gameType.name}'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
