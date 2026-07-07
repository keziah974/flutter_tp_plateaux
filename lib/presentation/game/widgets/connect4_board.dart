import 'package:flutter/material.dart';

import '../../../application/engines/connect4_engine.dart';
import '../../../domain/entities/game_state.dart' as domain;
import '../../../domain/entities/move.dart';
import '../../../domain/enums/game_status.dart';

class Connect4Board extends StatefulWidget {
  final domain.GameState state;
  final bool enabled;
  final ValueChanged<Move> onMove;

  const Connect4Board({
    super.key,
    required this.state,
    required this.enabled,
    required this.onMove,
  });

  @override
  State<Connect4Board> createState() => _Connect4BoardState();
}

class _Connect4BoardState extends State<Connect4Board> {
  int _previousMoveCount = 0;
  Move? _lastMove;

  @override
  void initState() {
    super.initState();
    _previousMoveCount = widget.state.history.length;
  }

  @override
  void didUpdateWidget(covariant Connect4Board oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.history.length > _previousMoveCount) {
      _lastMove = widget.state.history.last;
    }
    _previousMoveCount = widget.state.history.length;
  }

  void _handleColumnTap(int col) {
    final engine = Connect4Engine();
    final validMoves = engine.getValidMoves(widget.state);
    final move = validMoves.where((m) => m.toCol == col).toList();
    if (move.isEmpty) return;
    widget.onMove(move.first);
  }

  @override
  Widget build(BuildContext context) {
    final engine = Connect4Engine();
    final winningLine =
        widget.state.status == GameStatus.won ? engine.winningLine(widget.state) : null;

    return AspectRatio(
      aspectRatio: 7 / 6,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / 7;
            return Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 42,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemBuilder: (context, index) {
                    final r = index ~/ 7;
                    final c = index % 7;
                    final value = widget.state.board[r][c];
                    final isFallingCell = _lastMove != null &&
                        _lastMove!.toRow == r &&
                        _lastMove!.toCol == c;
                    final isWinningCell =
                        winningLine?.any((p) => p[0] == r && p[1] == c) ??
                            false;

                    return GestureDetector(
                      onTap: (widget.enabled)
                          ? () => _handleColumnTap(c)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey('$r-$c-$value-$isFallingCell'),
                          duration: Duration(
                            milliseconds: isFallingCell ? 350 : 0,
                          ),
                          curve: Curves.easeIn,
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, t, child) {
                            return Opacity(
                              opacity: value == 0 ? 1 : t,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  isFallingCell
                                      ? (1 - t) * -cellSize * (r + 1)
                                      : 0,
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: value == 0
                                  ? Colors.blue.shade900
                                  : (value == 1 ? Colors.red : Colors.yellow),
                              border: isWinningCell
                                  ? Border.all(
                                      color: Colors.white, width: 3)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
