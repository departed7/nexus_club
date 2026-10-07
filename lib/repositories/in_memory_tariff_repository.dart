import '../models/tariff.dart';
import 'tariff_repository.dart';

class InMemoryTariffRepository implements TariffRepository {
  final List<Tariff> _tariffs = const [
    // Тарифы для Зоны 1 (Standard)
    Tariff(id: 1, name: 'Пакет 3 часа (Standard)', zoneId: 1, durationHours: 3, price: 400),
    Tariff(id: 2, name: 'Пакет 5 часов (Standard)', zoneId: 1, durationHours: 5, price: 600),
    Tariff(id: 3, name: 'Ночной Non-Stop (Standard)', zoneId: 1, durationHours: 8, price: 850),
    // Тарифы для Зоны 2 (VIP Neon)
    Tariff(id: 4, name: 'Пакет 3 часа (VIP)', zoneId: 2, durationHours: 3, price: 900),
    Tariff(id: 5, name: 'Пакет 5 часов (VIP)', zoneId: 2, durationHours: 5, price: 1400),
    Tariff(id: 6, name: 'Ночной Non-Stop (VIP)', zoneId: 2, durationHours: 8, price: 2000),
    // Тарифы для Зоны 3 (Bootcamp)
    Tariff(id: 7, name: 'Пакет Team 5v5 (3 часа)', zoneId: 3, durationHours: 3, price: 3800),
    Tariff(id: 8, name: 'Пакет Team 5v5 (Ночь)', zoneId: 3, durationHours: 8, price: 8000),
  ];

  @override
  Future<List<Tariff>> findByZoneId(int zoneId) async {
    return _tariffs.where((t) => t.zoneId == zoneId).toList();
  }
}