import '../models/club_zone.dart';
import '../models/page_result.dart';
import '../models/zone_query.dart';
import 'zone_repository.dart';

class InMemoryZoneRepository implements ZoneRepository {
  final List<ClubZone> _zones = [
    const ClubZone(id: 1, name: 'Standard Hall', description: 'Основной зал: мониторы 165Hz, кресла Knight, периферия HyperX', hourlyPrice: 150.0),
    const ClubZone(id: 2, name: 'VIP Neon Room', description: 'Приватная неоновая зона: RTX 4080 Super, 280Hz ASUS ROG', hourlyPrice: 350.0),
    const ClubZone(id: 3, name: 'Bootcamp Pro 5v5', description: 'Шумоизолированная комната для кланваров, сетап 360Hz ZOWIE', hourlyPrice: 280.0),
    const ClubZone(id: 4, name: 'Streamer Studio', description: 'Студийный свет Elgato, Shure SM7B, зеркальная 4K камера', hourlyPrice: 500.0),
    const ClubZone(id: 5, name: 'PlayStation 5 Lounge', description: 'Диваны, PS5 Pro, 4K OLED панели 65" 120Hz', hourlyPrice: 200.0),
    const ClubZone(id: 6, name: 'VR Cyber Arena', description: 'Meta Quest 3 + Valve Index, трекинг всего тела', hourlyPrice: 400.0),
    const ClubZone(id: 7, name: 'Tournament Stage', description: 'Главная сцена с посадочными местами для чемпионатов', hourlyPrice: 450.0),
    const ClubZone(id: 8, name: 'Chill & Smoke Bar', description: 'Барная стойка с трансляциями Twitch и напитками', hourlyPrice: 100.0),
  ];

  @override
  Future<List<ClubZone>> findAllActive() async {
    return _zones.where((z) => !z.isDeleted).toList();
  }

  @override
  Future<PageResult<ClubZone>> find(ZoneQuery query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var rows = _zones.where((z) => query.includeDeleted || !z.isDeleted).toList();

    if (query.search.trim().isNotEmpty) {
      final needle = query.search.trim().toLowerCase();
      rows = rows.where((z) => z.name.toLowerCase().contains(needle) || z.description.toLowerCase().contains(needle)).toList();
    }

    rows.sort((a, b) {
      final res = switch (query.sortField) {
        'price' => a.hourlyPrice.compareTo(b.hourlyPrice),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return query.sortAscending ? res : -res;
    });

    final total = rows.length;
    final from = (query.page - 1) * query.size;
    final to = (from + query.size) > total ? total : (from + query.size);
    final items = from >= total ? <ClubZone>[] : rows.sublist(from, to);

    return PageResult(items: items, page: query.page, size: query.size, total: total);
  }

  @override
  Future<ClubZone?> findById(int id) async {
    try {
      return _zones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _zones.indexWhere((z) => z.id == id);
    if (i != -1) _zones[i] = _zones[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> restore(int id) async {
    final i = _zones.indexWhere((z) => z.id == id);
    if (i != -1) _zones[i] = _zones[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<void> hardDelete(int id) async {
    _zones.removeWhere((z) => z.id == id);
  }
}