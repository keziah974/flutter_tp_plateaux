import 'package:flutter/material.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Position sur le plateau (ligne, colonne). Classe UI uniquement.
@immutable
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

/// Pièces mock : 'w' = blanc, 'W' = dame blanche,
/// 'b' = noir, 'B' = dame noire.
final Map<Position, String> kMockCheckersPieces = {
  Position(0, 1): 'b', Position(0, 3): 'b', Position(0, 5): 'b',
  Position(1, 0): 'b', Position(1, 2): 'b', Position(1, 4): 'b',
  Position(7, 0): 'w', Position(7, 2): 'w', Position(7, 4): 'w',
  Position(8, 1): 'w', Position(8, 3): 'W',
};

/// Plateau de Dames 10x10 (mock, purement visuel).
/// - Cases claires/foncées selon le thème
/// - Case sélectionnée : bordure accent
/// - Coups valides : cercle vert semi-transparent
/// - Déplacement : AnimatedPositioned 300ms
/// - Prise : disparition en fondu 200ms
class CheckersBoard extends StatefulWidget {
  /// Si null, utilise [kMockCheckersPieces].
  final Map<Position, String>? pieces;

  const CheckersBoard({super.key, this.pieces});

  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
}

class _PieceData {
  Position position;
  final String code;
  bool dying = false;

  _PieceData(this.position, this.code);
}

class _CheckersBoardState extends State<CheckersBoard> {
  static const int boardSize = 10;

  late final Map<int, _PieceData> _pieces;
  Position? _selected;
  List<Position> _validMoves = const [];

  @override
  void initState() {
    super.initState();
    var id = 0;
    _pieces = {
      for (final entry in (widget.pieces ?? kMockCheckersPieces).entries)
        id++: _PieceData(entry.key, entry.value),
    };
    // Sélection d'exemple : la dame blanche.
    final dame = _pieces.entries
        .where((e) => e.value.code == 'W')
        .map((e) => e.value.position);
    if (dame.isNotEmpty) {
      _selected = dame.first;
      _validMoves = _movesFrom(dame.first);
    }
  }

  _PieceData? _pieceAt(Position pos) {
    for (final piece in _pieces.values) {
      if (!piece.dying && piece.position == pos) return piece;
    }
    return null;
  }

  bool _inBoard(Position pos) =>
      pos.row >= 0 &&
      pos.row < boardSize &&
      pos.col >= 0 &&
      pos.col < boardSize;

  /// Mock : cases diagonales voisines libres, ou saut par-dessus
  /// une pièce adverse.
  List<Position> _movesFrom(Position from) {
    final piece = _pieceAt(from);
    if (piece == null) return const [];
    final isWhite = piece.code.toLowerCase() == 'w';
    final moves = <Position>[];
    for (final dr in [-1, 1]) {
      for (final dc in [-1, 1]) {
        final step = Position(from.row + dr, from.col + dc);
        if (!_inBoard(step)) continue;
        final occupant = _pieceAt(step);
        if (occupant == null) {
          moves.add(step);
        } else if ((occupant.code.toLowerCase() == 'w') != isWhite) {
          final jump = Position(from.row + dr * 2, from.col + dc * 2);
          if (_inBoard(jump) && _pieceAt(jump) == null) moves.add(jump);
        }
      }
    }
    return moves;
  }

  void _handleTap(Position pos) {
    final tappedPiece = _pieceAt(pos);
    if (tappedPiece != null) {
      setState(() {
        _selected = pos;
        _validMoves = _movesFrom(pos);
      });
      return;
    }
    if (_selected != null && _validMoves.contains(pos)) {
      final moving = _pieceAt(_selected!);
      if (moving == null) return;
      setState(() {
        // Prise : la pièce sautée disparaît en fondu.
        if ((pos.row - _selected!.row).abs() == 2) {
          final middle = Position(
            (pos.row + _selected!.row) ~/ 2,
            (pos.col + _selected!.col) ~/ 2,
          );
          final captured = _pieceAt(middle);
          if (captured != null) captured.dying = true;
        }
        moving.position = pos;
        _selected = null;
        _validMoves = const [];
      });
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) {
          setState(() => _pieces.removeWhere((_, p) => p.dying));
        }
      });
      return;
    }
    setState(() {
      _selected = null;
      _validMoves = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: type == AppThemeType.ancien
              ? colors.secondary
              : colors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.boardBorder,
            width: type == AppThemeType.ancien ? 4 : 1.5,
          ),
          boxShadow: [
            if (type == AppThemeType.ancien)
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            else
              BoxShadow(
                color: colors.boardBorder.withValues(alpha: 0.25),
                blurRadius: 18,
              ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / boardSize;
            return Stack(
              children: [
                // Cases du damier.
                Column(
                  children: [
                    for (var row = 0; row < boardSize; row++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var col = 0; col < boardSize; col++)
                              Expanded(
                                child: _buildSquare(Position(row, col)),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                // Pièces par-dessus, animées en position.
                for (final entry in _pieces.entries)
                  AnimatedPositioned(
                    key: ValueKey(entry.key),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: entry.value.position.col * cellSize,
                    top: entry.value.position.row * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: AnimatedOpacity(
                      opacity: entry.value.dying ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handleTap(entry.value.position),
                        child: _CheckerPiece(code: entry.value.code),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSquare(Position pos) {
    final colors = context.appColors;
    final isDarkSquare = (pos.row + pos.col) % 2 == 1;
    final isSelected = _selected == pos;
    final isValidMove = _validMoves.contains(pos);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(pos),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkSquare ? colors.boardDark : colors.boardLight,
          border: isSelected
              ? Border.all(color: colors.accent, width: 2.5)
              : null,
        ),
        child: isValidMove
            ? Center(
                child: FractionallySizedBox(
                  widthFactor: 0.45,
                  heightFactor: 0.45,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Pièce de dames : cercle ombré, couronne pour les dames.
class _CheckerPiece extends StatelessWidget {
  final String code;

  const _CheckerPiece({required this.code});

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final isWhite = code.toLowerCase() == 'w';
    final isKing = code == 'W' || code == 'B';
    final color = isWhite ? colors.piece2 : colors.piece1;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              Color.lerp(color, Colors.black, 0.35)!,
            ],
          ),
          border: type == AppThemeType.ancien
              ? Border.all(color: colors.boardBorder, width: 2)
              : Border.all(
                  color: color.withValues(alpha: 0.8),
                ),
          boxShadow: [
            if (type == AppThemeType.ancien)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
          ],
        ),
        child: isKing
            ? Center(
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: type == AppThemeType.ancien
                      ? colors.boardBorder
                      : colors.winHighlight,
                ),
              )
            : null,
      ),
    );
  }
}
