import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/game/game_bloc.dart';
import '../../application/game/game_event.dart';

class GameOverDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const GameOverDialog({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Text(subtitle, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/home');
          },
          child: const Text('Menu'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<GameBloc>().add(const GameReset());
          },
          child: const Text('Rejouer'),
        ),
      ],
    );
  }
}
