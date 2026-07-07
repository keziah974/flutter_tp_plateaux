import 'package:flutter/material.dart';

import '../../../application/engines/tic_tac_toe_engine.dart';
import '../../../domain/entities/game_state.dart' as domain;
import '../../../domain/entities/move.dart';
import '../../../domain/enums/game_status.dart';

class TicTacToeBoard extends StatelessWidget {
  final domain.GameState state;
  final bool enabled;
  final ValueChanged<Move> onMove;

  const TicTacToeBoard({
    super.key,
    required this.state,
    required this.enabled,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final engine = TicTacToeEngine();
    final winningLine =
        state.status == GameStatus.won ? engine.winningLine(state) : null;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final r = index ~/ 3;
            final c = index % 3;
            final value = state.board[r][c];
            final isWinningCell =
                winningLine?.any((p) => p[0] == r && p[1] == c) ?? false;

            return _Cell(
              value: value,
              highlighted: isWinningCell,
              onTap: (enabled && value == 0)
                  ? () => onMove(Move(toRow: r, toCol: c))
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final int value;
  final bool highlighted;
  final VoidCallback? onTap;

  const _Cell({required this.value, required this.highlighted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? Colors.amber.withValues(alpha: 0.3)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: value == 0
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : Text(
                    value == 1 ? 'X' : 'O',
                    key: ValueKey(value),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: value == 1 ? Colors.red : Colors.blue,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
