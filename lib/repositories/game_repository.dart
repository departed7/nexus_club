import '../models/game.dart';

abstract interface class GameRepository {
  Future<List<Game>> findAllActive();
  Future<Game?> findById(int id);
}