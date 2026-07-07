import 'package:flutter/material.dart';

import '../../../application/engines/checkers_engine.dart';
import '../../../domain/entities/game_state.dart' as domain;
import '../../../domain/entities/move.dart';
import '../../../domain/enums/player.dart';

class CheckersBoard extends StatefulWidget {
  final domain.GameState state;
  final bool enabled;
  final ValueChanged<Move> onMove;

  const CheckersBoard({
    super.key,
    required this.state,
    required this.enabled,
    required this.onMove,
  });

  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
}

class _CheckersBoardState extends State<CheckersBoard> {
  List<int>? _selected;
  List<Move> _availableMoves = [];

  @override
  void didUpdateWidget(covariant CheckersBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _selected = null;
      _availableMoves = [];
    }
  }

  void _handleTap(int r, int c) {
    if (!widget.enabled) return;
    final engine = CheckersEngine();
    final allMoves = engine.getValidMoves(widget.state);

    final destinationMove = _availableMoves.firstWhere(
      (m) => m.toRow == r && m.toCol == c,
      orElse: () => const Move(toRow: -1, toCol: -1),
    );
    if (destinationMove.toRow != -1) {
      widget.onMove(destinationMove);
      setState(() {
        _selected = null;
        _availableMoves = [];
      });
      return;
    }

    final ownerCode = widget.state.board[r][c];
    final ownsPiece = ownerCode != 0 &&
        ((widget.state.currentPlayer == Player.playerOne &&
                (ownerCode == 1 || ownerCode == 3)) ||
            (widget.state.currentPlayer == Player.playerTwo &&
                (ownerCode == 2 || ownerCode == 4)));

    if (!ownsPiece) {
      setState(() {
        _selected = null;
        _availableMoves = [];
      });
      return;
    }

    final movesForPiece =
        allMoves.where((m) => m.fromRow == r && m.fromCol == c).toList();
    setState(() {
      if (movesForPiece.isEmpty) {
        _selected = null;
        _availableMoves = [];
      } else {
        _selected = [r, c];
        _availableMoves = movesForPiece;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade800, width: 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 100,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
          ),
          itemBuilder: (context, index) {
            final r = index ~/ 10;
            final c = index % 10;
            final isDark = (r + c) % 2 == 1;
            final value = widget.state.board[r][c];
            final isSelected =
                _selected != null && _selected![0] == r && _selected![1] == c;
            final isAvailable =
                _availableMoves.any((m) => m.toRow == r && m.toCol == c);

            return GestureDetector(
              onTap: isDark ? () => _handleTap(r, c) : null,
              child: Container(
                color: isSelected
                    ? Colors.amber.shade300
                    : (isDark ? Colors.brown.shade700 : Colors.brown.shade100),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isAvailable)
                      Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent.withValues(alpha: 0.6),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: value == 0
                          ? const SizedBox.shrink(key: ValueKey('empty'))
                          : _Piece(key: ValueKey(value), code: value),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Piece extends StatelessWidget {
  final int code;
  const _Piece({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isPlayerOne = code == 1 || code == 3;
    final isKing = code == 3 || code == 4;
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlayerOne ? Colors.red.shade700 : Colors.grey.shade900,
        border: Border.all(color: Colors.black26, width: 2),
      ),
      child: isKing
          ? const Center(
              child: Icon(Icons.stars, color: Colors.amber, size: 18),
            )
          : null,
    );
  }
}
