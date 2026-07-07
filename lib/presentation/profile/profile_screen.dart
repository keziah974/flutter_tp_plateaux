import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/score_model.dart';
import '../../domain/entities/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _avatarOverride;

  Future<void> _pickAvatar(UserModel user) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return GridView.count(
          crossAxisCount: 5,
          padding: const EdgeInsets.all(16),
          children: AppConstants.avatarEmojis.map((emoji) {
            return IconButton(
              onPressed: () => Navigator.of(context).pop(emoji),
              icon: Text(emoji, style: const TextStyle(fontSize: 28)),
            );
          }).toList(),
        );
      },
    );
    if (emoji == null || !mounted) return;

    setState(() => _avatarOverride = emoji);
    await ServiceLocator.instance.userRepository.updateUser(
      user.copyWith(avatarEmoji: emoji),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar mis à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;
    final avatarEmoji = _avatarOverride ?? user.avatarEmoji;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickAvatar(user),
                child: CircleAvatar(
                  radius: 44,
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _pickAvatar(user),
                child: const Text('Changer l\'avatar'),
              ),
              Text(user.pseudo, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<ScoreModel>>(
                  future: ServiceLocator.instance.scoreRepository
                      .getScoresForUser(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final scores = snapshot.data ?? [];
                    final wins = scores.fold<int>(0, (s, e) => s + e.wins);
                    final losses = scores.fold<int>(0, (s, e) => s + e.losses);
                    final draws = scores.fold<int>(0, (s, e) => s + e.draws);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(label: 'Victoires', value: wins),
                            _StatColumn(label: 'Défaites', value: losses),
                            _StatColumn(label: 'Nuls', value: draws),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/stats'),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Voir les statistiques détaillées'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
