import '../models/tariff.dart';

abstract interface class TariffRepository {
  Future<List<Tariff>> findByZoneId(int zoneId);
}