import 'package:flutter/material.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Grille mock : 0 = vide, 1 = joueur 1, 2 = joueur 2.
const List<List<int>> kMockConnect4Grid = [
  [0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 1, 0, 0, 0],
  [0, 0, 1, 2, 0, 0, 0],
  [0, 1, 2, 2, 1, 0, 0],
  [1, 2, 1, 2, 2, 1, 0],
];

/// Plateau Puissance 4 (mock, purement visuel).
/// - Cercles vides légèrement transparents
/// - Animation de chute (300ms, bounceOut) sur la dernière pièce jouée
/// - Flèche indicatrice sur la colonne tapée
/// - Highlight pulse sur les 4 cercles gagnants
class Connect4Board extends StatefulWidget {
  final List<List<int>> grid;
  final List<(int, int)> winningCells;
  final void Function(int col)? onColumnTap;

  const Connect4Board({
    super.key,
    this.grid = kMockConnect4Grid,
    this.winningCells = const [],
    this.onColumnTap,
  });

  @override
  State<Connect4Board> createState() => _Connect4BoardState();
}

class _Connect4BoardState extends State<Connect4Board>
    with SingleTickerProviderStateMixin {
  static const int rows = 6;
  static const int cols = 7;

  late List<List<int>> _grid;
  late final AnimationController _winPulse;
  int? _hoverCol;
  (int, int)? _lastDrop;
  int _dropCount = 0;
  int _nextPlayer = 2;

  @override
  void initState() {
    super.initState();
    _grid = [for (final row in widget.grid) [...row]];
    _winPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.winningCells.isNotEmpty) _winPulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(Connect4Board oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.grid != oldWidget.grid) {
      _grid = [for (final row in widget.grid) [...row]];
    }
    if (widget.winningCells.isNotEmpty && !_winPulse.isAnimating) {
      _winPulse.repeat(reverse: true);
    } else if (widget.winningCells.isEmpty && _winPulse.isAnimating) {
      _winPulse.stop();
      _winPulse.value = 0;
    }
  }

  @override
  void dispose() {
    _winPulse.dispose();
    super.dispose();
  }

  /// Interaction mock : fait tomber une pièce dans la colonne.
  void _dropIn(int col) {
    for (var row = rows - 1; row >= 0; row--) {
      if (_grid[row][col] == 0) {
        setState(() {
          _grid[row][col] = _nextPlayer;
          _lastDrop = (row, col);
          _dropCount++;
          _nextPlayer = _nextPlayer == 1 ? 2 : 1;
          _hoverCol = null;
        });
        widget.onColumnTap?.call(col);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;

    return AspectRatio(
      aspectRatio: cols / (rows + 1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / cols;
          return Column(
            children: [
              // Rangée des flèches indicatrices.
              SizedBox(
                height: cellSize,
                child: Row(
                  children: [
                    for (var col = 0; col < cols; col++)
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _hoverCol == col ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: cellSize * 0.9,
                            color: colors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: type == AppThemeType.ancien
                        ? colors.boardDark
                        : colors.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.boardBorder.withValues(alpha: 0.8),
                      width: type == AppThemeType.ancien ? 3 : 1.4,
                    ),
                    boxShadow: type == AppThemeType.futuriste
                        ? [
                            BoxShadow(
                              color: colors.boardBorder
                                  .withValues(alpha: 0.25),
                              blurRadius: 18,
                            ),
                          ]
                        : const [],
                  ),
                  child: Row(
                    children: [
                      for (var col = 0; col < cols; col++)
                        Expanded(child: _buildColumn(col, cellSize)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumn(int col, double cellSize) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _hoverCol = col),
      onTapCancel: () => setState(() => _hoverCol = null),
      onTap: () => _dropIn(col),
      child: Column(
        children: [
          for (var row = 0; row < rows; row++)
            Expanded(child: _buildCell(row, col, cellSize)),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final colors = context.appColors;
    final value = _grid[row][col];
    final isWinning = widget.winningCells.contains((row, col));
    final isLastDrop = _lastDrop == (row, col);

    Widget piece;
    if (value == 0) {
      piece = _EmptySlot(size: cellSize);
    } else {
      piece = _Piece(player: value, size: cellSize);
      if (isLastDrop) {
        // Chute depuis le haut du plateau jusqu'à la case finale.
        final fallDistance = (row + 1) * cellSize;
        piece = TweenAnimationBuilder<double>(
          key: ValueKey('drop$_dropCount'),
          tween: Tween(begin: -fallDistance, end: 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.bounceOut,
          builder: (context, dy, child) =>
              Transform.translate(offset: Offset(0, dy), child: child),
          child: piece,
        );
      }
    }

    return AnimatedBuilder(
      animation: _winPulse,
      builder: (context, child) {
        return Container(
          decoration: isWinning
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.winHighlight.withValues(
                        alpha: 0.3 + 0.5 * _winPulse.value,
                      ),
                      blurRadius: 12 + 8 * _winPulse.value,
                    ),
                  ],
                )
              : null,
          child: child,
        );
      },
      child: Center(child: piece),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final double size;

  const _EmptySlot({required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size * 0.78,
      height: size * 0.78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.background.withValues(alpha: 0.45),
        border: Border.all(
          color: colors.boardBorder.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _Piece extends StatelessWidget {
  final int player;
  final double size;

  const _Piece({required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final color = player == 1 ? colors.piece1 : colors.piece2;

    return Container(
      width: size * 0.78,
      height: size * 0.78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: type == AppThemeType.cosmos
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: player == 1
                    ? [colors.piece1, const Color(0xFF7B2FFF)]
                    : [colors.piece2, const Color(0xFFB33920)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  Color.lerp(color, Colors.black, 0.35)!,
                ],
              ),
        border: type == AppThemeType.ancien
            ? Border.all(color: colors.boardBorder, width: 2)
            : null,
        boxShadow: [
          if (type == AppThemeType.ancien)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 10,
            ),
        ],
      ),
    );
  }
}
