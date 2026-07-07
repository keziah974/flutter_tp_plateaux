import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/service_locator.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_type.dart';
import 'game_navigation_args.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final String gameType;
  const DifficultySelectionScreen({super.key, required this.gameType});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState
    extends State<DifficultySelectionScreen> {
  Difficulty? _selected;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDifficulty();
  }

  Future<void> _loadSavedDifficulty() async {
    final saved = await ServiceLocator.instance.localStorageRepository
        .getDifficulty(GameType.values.byName(widget.gameType));
    if (!mounted) return;
    setState(() {
      _selected = saved ?? Difficulty.medium;
      _loaded = true;
    });
  }

  void _confirm(Difficulty difficulty) {
    GameNavigationArgs.difficulty = difficulty;
    context.push('/game/${widget.gameType}');
  }

  @override
  Widget build(BuildContext context) {
    final type = GameType.values.byName(widget.gameType);

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Choisis une difficulté',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 32),
                    for (final difficulty in Difficulty.values) ...[
                      _DifficultyButton(
                        difficulty: difficulty,
                        selected: _selected == difficulty,
                        onTap: () => _confirm(difficulty),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  String get _label {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Facile';
      case Difficulty.medium:
        return 'Moyen';
      case Difficulty.hard:
        return 'Difficile';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text('$_label ✓'),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(_label),
      ),
    );
  }
}
