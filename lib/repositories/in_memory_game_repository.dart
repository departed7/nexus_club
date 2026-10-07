import '../models/game.dart';
import 'game_repository.dart';

class InMemoryGameRepository implements GameRepository {
  final List<Game> _games = const [
    Game(id: 1, title: 'Counter-Strike 2', genre: 'Тактический шутер', storageGb: 40),
    Game(id: 2, title: 'Dota 2', genre: 'MOBA', storageGb: 45),
    Game(id: 3, title: 'Cyberpunk 2077: Phantom Liberty', genre: 'Action RPG', storageGb: 85),
    Game(id: 4, title: 'Valorant', genre: 'Тактический шутер', storageGb: 35),
    Game(id: 5, title: 'Grand Theft Auto V', genre: 'Экшен', storageGb: 110),
    Game(id: 6, title: 'Apex Legends', genre: 'Королевская битва', storageGb: 65),
  ];

  @override
  Future<List<Game>> findAllActive() async {
    return _games.where((g) => !g.isDeleted).toList();
  }

  @override
  Future<Game?> findById(int id) async {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}