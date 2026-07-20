import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

/// Grille mock : null = vide, 'X' = joueur 1, 'O' = joueur 2.
const List<List<String?>> kMockTicTacToeGrid = [
  [null, 'X', null],
  ['O', 'X', null],
  [null, null, 'O'],
];

/// Plateau de Morpion (mock, purement visuel).
/// - Séparateurs stylés selon le thème
/// - Apparition des symboles en scale (AnimatedSwitcher)
/// - Tap cellule → highlight temporaire
/// - Ligne gagnante → pulse de couleur
class TicTacToeBoard extends StatefulWidget {
  final List<List<String?>> grid;
  final List<(int, int)> winningLine;
  final void Function(int row, int col)? onCellTap;

  const TicTacToeBoard({
    super.key,
    this.grid = kMockTicTacToeGrid,
    this.winningLine = const [],
    this.onCellTap,
  });

  @override
  State<TicTacToeBoard> createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _winPulse;
  (int, int)? _tapped;
  Timer? _tapTimer;

  @override
  void initState() {
    super.initState();
    _winPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.winningLine.isNotEmpty) _winPulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TicTacToeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.winningLine.isNotEmpty && !_winPulse.isAnimating) {
      _winPulse.repeat(reverse: true);
    } else if (widget.winningLine.isEmpty && _winPulse.isAnimating) {
      _winPulse.stop();
      _winPulse.value = 0;
    }
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _winPulse.dispose();
    super.dispose();
  }

  void _handleTap(int row, int col) {
    setState(() => _tapped = (row, col));
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _tapped = null);
    });
    widget.onCellTap?.call(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: type == AppThemeType.ancien
              ? colors.boardLight.withValues(alpha: 0.15)
              : colors.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.boardBorder.withValues(alpha: 0.7),
            width: type == AppThemeType.ancien ? 3 : 1.2,
          ),
          boxShadow: type == AppThemeType.futuriste
              ? [
                  BoxShadow(
                    color: colors.boardBorder.withValues(alpha: 0.25),
                    blurRadius: 20,
                  ),
                ]
              : const [],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _SeparatorsPainter(type, colors)),
            ),
            Column(
              children: [
                for (var row = 0; row < 3; row++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < 3; col++)
                          Expanded(child: _buildCell(row, col)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final colors = context.appColors;
    final value = widget.grid[row][col];
    final isWinning = widget.winningLine.contains((row, col));
    final isTapped = _tapped == (row, col);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(row, col),
      child: AnimatedBuilder(
        animation: _winPulse,
        builder: (context, child) {
          Color highlight = Colors.transparent;
          if (isWinning) {
            highlight = colors.winHighlight
                .withValues(alpha: 0.15 + 0.3 * _winPulse.value);
          } else if (isTapped) {
            highlight = colors.primary.withValues(alpha: 0.2);
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          );
        },
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: value == null
                ? const SizedBox.shrink()
                : _Symbol(key: ValueKey('$row$col$value'), value: value),
          ),
        ),
      ),
    );
  }
}

/// X / O stylé selon le thème :
/// - Futuriste : néon lumineux
/// - Ancien : gravé dans le bois
/// - Cosmos : étoile pour X, planète pour O
class _Symbol extends StatelessWidget {
  final String value;

  const _Symbol({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final isX = value == 'X';
    final color = isX ? colors.piece1 : colors.piece2;

    switch (type) {
      case AppThemeType.futuriste:
        return Text(
          isX ? '✕' : '◯',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.9), blurRadius: 16),
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 32),
            ],
          ),
        );
      case AppThemeType.ancien:
        return Text(
          isX ? '✕' : '◯',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w800,
            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.55),
                offset: const Offset(1.5, 2),
                blurRadius: 2,
              ),
              Shadow(
                color: colors.accent.withValues(alpha: 0.25),
                offset: const Offset(-1, -1),
                blurRadius: 1,
              ),
            ],
          ),
        );
      case AppThemeType.cosmos:
        if (isX) {
          return Text(
            '✦',
            style: TextStyle(
              fontSize: 50,
              color: colors.primary,
              shadows: [
                Shadow(
                  color: colors.primary.withValues(alpha: 0.8),
                  blurRadius: 18,
                ),
              ],
            ),
          );
        }
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.accent, const Color(0xFFB33920)],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.6),
                blurRadius: 14,
              ),
            ],
          ),
        );
    }
  }
}

/// Séparateurs de la grille 3x3 :
/// - Futuriste : lignes néon cyan
/// - Ancien : bois sculpté (double trait sombre/clair)
/// - Cosmos : lignes dorées
class _SeparatorsPainter extends CustomPainter {
  final AppThemeType type;
  final AppColors colors;

  const _SeparatorsPainter(this.type, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final third = size.width / 3;
    const inset = 10.0;

    void drawLines(Paint paint, {Offset shift = Offset.zero}) {
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(third * i, inset) + shift,
          Offset(third * i, size.height - inset) + shift,
          paint,
        );
        canvas.drawLine(
          Offset(inset, third * i) + shift,
          Offset(size.width - inset, third * i) + shift,
          paint,
        );
      }
    }

    switch (type) {
      case AppThemeType.futuriste:
        final glow = Paint()
          ..color = colors.primary.withValues(alpha: 0.35)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        drawLines(glow);
        final core = Paint()
          ..color = colors.primary
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        drawLines(core);
      case AppThemeType.ancien:
        final dark = Paint()
          ..color = Colors.black.withValues(alpha: 0.55)
          ..strokeWidth = 3;
        drawLines(dark);
        final light = Paint()
          ..color = colors.accent.withValues(alpha: 0.25)
          ..strokeWidth = 1.5;
        drawLines(light, shift: const Offset(1.5, 1.5));
      case AppThemeType.cosmos:
        final gold = Paint()
          ..color = colors.primary.withValues(alpha: 0.8)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;
        drawLines(gold);
    }
  }

  @override
  bool shouldRepaint(_SeparatorsPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.colors != colors;
}
