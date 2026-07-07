import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/score_model.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_type.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _difficultyLabel(Difficulty? difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Facile';
      case Difficulty.medium:
        return 'Moyen';
      case Difficulty.hard:
        return 'Difficile';
      case null:
        return '2 joueurs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: authState is! AuthAuthenticated
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ScoreModel>>(
              future: ServiceLocator.instance.scoreRepository
                  .getScoresForUser(authState.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final scores = [...(snapshot.data ?? [])];
                if (scores.isEmpty) {
                  return const Center(
                    child: Text('Aucune partie enregistrée pour le moment.'),
                  );
                }

                scores.sort((a, b) {
                  final byGame = a.gameType.index.compareTo(b.gameType.index);
                  if (byGame != 0) return byGame;
                  return (a.difficulty?.index ?? -1)
                      .compareTo(b.difficulty?.index ?? -1);
                });

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final gameType in GameType.values) ...[
                      if (scores.any((s) => s.gameType == gameType)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            gameType.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Mode')),
                              DataColumn(label: Text('V')),
                              DataColumn(label: Text('D')),
                              DataColumn(label: Text('N')),
                            ],
                            rows: scores
                                .where((s) => s.gameType == gameType)
                                .map(
                                  (s) => DataRow(cells: [
                                    DataCell(
                                        Text(_difficultyLabel(s.difficulty))),
                                    DataCell(Text('${s.wins}')),
                                    DataCell(Text('${s.losses}')),
                                    DataCell(Text('${s.draws}')),
                                  ]),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ],
                );
              },
            ),
    );
  }
}
