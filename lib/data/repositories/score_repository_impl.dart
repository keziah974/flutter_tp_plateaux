import '../../domain/entities/score_model.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/game_type.dart';
import '../../domain/repositories/score_repository.dart';
import '../datasources/firestore_datasource.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final FirestoreDatasource _firestoreDatasource;

  ScoreRepositoryImpl({required this._firestoreDatasource});

  String _docId(String userId, GameType gameType, Difficulty? difficulty) {
    final suffix = difficulty == null ? 'multiplayer' : difficulty.name;
    return '${userId}_${gameType.name}_$suffix';
  }

  @override
  Future<List<ScoreModel>> getScoresForUser(String userId) async {
    final snapshot = await _firestoreDatasource.getScoresForUser(userId);
    return snapshot.docs.map(ScoreModel.fromFirestore).toList();
  }

  @override
  Future<void> recordResult({
    required String userId,
    required GameType gameType,
    Difficulty? difficulty,
    required bool won,
    required bool draw,
  }) async {
    final docId = _docId(userId, gameType, difficulty);
    final existingDoc = await _firestoreDatasource.getScoreDoc(docId);

    final current = existingDoc.exists
        ? ScoreModel.fromFirestore(existingDoc)
        : ScoreModel(
            id: docId,
            userId: userId,
            gameType: gameType,
            difficulty: difficulty,
            wins: 0,
            losses: 0,
            draws: 0,
            updatedAt: DateTime.now(),
          );

    final updated = current.copyWith(
      wins: current.wins + (won && !draw ? 1 : 0),
      losses: current.losses + (!won && !draw ? 1 : 0),
      draws: current.draws + (draw ? 1 : 0),
    );

    await _firestoreDatasource.upsertScore(docId, updated.toMap());
  }
}
