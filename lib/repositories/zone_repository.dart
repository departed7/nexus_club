import '../models/club_zone.dart';
import '../models/page_result.dart';
import '../models/zone_query.dart';

abstract interface class ZoneRepository {
  Future<PageResult<ClubZone>> find(ZoneQuery query);
  Future<ClubZone?> findById(int id);
  Future<List<ClubZone>> findAllActive();
  Future<void> softDelete(int id);
  Future<void> restore(int id);
  Future<void> hardDelete(int id);
}