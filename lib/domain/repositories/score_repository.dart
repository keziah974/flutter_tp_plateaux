import '../entities/score_model.dart';
import '../enums/difficulty.dart';
import '../enums/game_type.dart';

abstract class ScoreRepository {
  Future<List<ScoreModel>> getScoresForUser(String userId);

  Future<void> recordResult({
    required String userId,
    required GameType gameType,
    Difficulty? difficulty,
    required bool won,
    required bool draw,
  });
}
