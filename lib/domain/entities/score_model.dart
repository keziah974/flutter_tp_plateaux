import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../enums/difficulty.dart';
import '../enums/game_type.dart';

class ScoreModel extends Equatable {
  final String id;
  final String userId;
  final GameType gameType;
  final Difficulty? difficulty;
  final int wins;
  final int losses;
  final int draws;
  final DateTime updatedAt;

  const ScoreModel({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.updatedAt,
    this.difficulty,
  });

  factory ScoreModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ScoreModel(
      id: doc.id,
      userId: data['userId'] as String,
      gameType: GameType.values.byName(data['gameType'] as String),
      difficulty: data['difficulty'] == null
          ? null
          : Difficulty.values.byName(data['difficulty'] as String),
      wins: data['wins'] as int? ?? 0,
      losses: data['losses'] as int? ?? 0,
      draws: data['draws'] as int? ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gameType': gameType.name,
      'difficulty': difficulty?.name,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ScoreModel copyWith({int? wins, int? losses, int? draws}) {
    return ScoreModel(
      id: id,
      userId: userId,
      gameType: gameType,
      difficulty: difficulty,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, gameType, difficulty, wins, losses, draws, updatedAt];
}
