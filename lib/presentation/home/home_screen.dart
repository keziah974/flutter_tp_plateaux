import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_event.dart';
import '../../application/auth/auth_state.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_model.dart';
import '../../domain/enums/game_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final pseudo =
        authState is AuthAuthenticated ? authState.user.pseudo : 'Joueur';
    final avatarEmoji =
        authState is AuthAuthenticated ? authState.user.avatarEmoji : '🎲';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Board'),
        actions: [
          BlocBuilder<ThemeCubit, AppThemeType>(
            builder: (context, themeType) {
              return IconButton(
                tooltip: 'Changer de thème',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () {
                  final next = AppThemeType.values[
                      (themeType.index + 1) % AppThemeType.values.length];
                  context.read<ThemeCubit>().switchTheme(next);
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(avatarEmoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pseudo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Bienvenue !',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Profil',
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Choisis un jeu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.2,
                  children: [
                    _GameCard(
                      emoji: '⭕',
                      gameType: GameType.ticTacToe,
                    ),
                    _GameCard(
                      emoji: '🔴',
                      gameType: GameType.connect4,
                    ),
                    _GameCard(
                      emoji: '♟️',
                      gameType: GameType.checkers,
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/stats'),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Statistiques'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji;
  final GameType gameType;

  const _GameCard({required this.emoji, required this.gameType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/mode-select/${gameType.name}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  gameType.label,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
