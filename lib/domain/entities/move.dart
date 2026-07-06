import 'package:equatable/equatable.dart';

/// A generic board move expressed in row/col coordinates.
///
/// For Tic-Tac-Toe and Connect 4 only [toRow]/[toCol] are meaningful
/// ([fromRow]/[fromCol] stay null). For Checkers a move is a slide or
/// capture from one square to another, optionally chained further
/// captures via [capturedPositions].
class Move extends Equatable {
  final int? fromRow;
  final int? fromCol;
  final int toRow;
  final int toCol;
  final List<List<int>> capturedPositions;
  final bool isPromotion;

  const Move({
    this.fromRow,
    this.fromCol,
    required this.toRow,
    required this.toCol,
    this.capturedPositions = const [],
    this.isPromotion = false,
  });

  bool get isCapture => capturedPositions.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'fromRow': fromRow,
      'fromCol': fromCol,
      'toRow': toRow,
      'toCol': toCol,
      'capturedPositions': capturedPositions,
      'isPromotion': isPromotion,
    };
  }

  factory Move.fromMap(Map<String, dynamic> map) {
    return Move(
      fromRow: map['fromRow'] as int?,
      fromCol: map['fromCol'] as int?,
      toRow: map['toRow'] as int,
      toCol: map['toCol'] as int,
      capturedPositions: (map['capturedPositions'] as List<dynamic>? ?? [])
          .map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
      isPromotion: map['isPromotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [fromRow, fromCol, toRow, toCol, capturedPositions, isPromotion];
}
