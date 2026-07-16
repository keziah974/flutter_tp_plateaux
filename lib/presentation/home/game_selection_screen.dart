import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../../domain/enums/game_type.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_card.dart';

/// Choix du mode de jeu (1 joueur contre l'IA ou 2 joueurs locaux)
/// pour le jeu sélectionné. Les cards entrent en glissant depuis le bas.
class GameSelectionScreen extends StatefulWidget {
  final String gameType;

  const GameSelectionScreen({super.key, required this.gameType});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  GameType get _game => GameType.values.firstWhere(
        (g) => g.name == widget.gameType,
        orElse: () => GameType.ticTacToe,
      );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<Offset> _slideFor(double delay) {
    return Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: Text(_game.label),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Comment veux-tu jouer ?',
                  textAlign: TextAlign.center,
                  style: typography.displayMedium,
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _slideFor(0),
                  child: _ModeCard(
                    emoji: '🤖',
                    title: '1 Joueur',
                    subtitle: "Affronte l'IA",
                    onTap: () =>
                        context.push('/difficulty/${widget.gameType}'),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _slideFor(0.25),
                  child: _ModeCard(
                    emoji: '👥',
                    title: '2 Joueurs',
                    subtitle: 'Sur le même écran',
                    onTap: () =>
                        context.push('/game/${widget.gameType}?mode=2p'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return ThemedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: typography.displayMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: typography.bodyMedium),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.primary),
        ],
      ),
    );
  }
}
