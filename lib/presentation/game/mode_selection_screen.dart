import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/enums/game_status.dart';
import '../../domain/enums/game_type.dart';
import 'game_navigation_args.dart';

class ModeSelectionScreen extends StatelessWidget {
  final String gameType;
  const ModeSelectionScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    final type = GameType.values.byName(gameType);

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choisis un mode de jeu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('1 Joueur (contre le bot)'),
                ),
                onPressed: () {
                  GameNavigationArgs.mode = GameMode.singlePlayer;
                  context.push('/difficulty/$gameType');
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.people_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('2 Joueurs (local)'),
                ),
                onPressed: () {
                  GameNavigationArgs.mode = GameMode.twoPlayers;
                  GameNavigationArgs.difficulty = null;
                  context.push('/game/$gameType');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
