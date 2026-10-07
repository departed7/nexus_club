import 'package:dio/dio.dart';
import '../../../core/api_exceptions.dart';
import '../../../models/club_zone.dart';
import '../../../models/page_result.dart';
import '../../../models/zone_query.dart';
import '../../../repositories/zone_repository.dart';

class ApiZoneRepository implements ZoneRepository {
  final Dio _dio;
  List<ClubZone>? _cachedZones; // Кэширование справочника (Критерий 15)

  ApiZoneRepository(this._dio);

  @override
  Future<List<ClubZone>> findAllActive() => guard(() async {
    if (_cachedZones != null) return _cachedZones!;
    final response = await _dio.get('/zones');
    final list = (response.data as List)
        .map((e) => ClubZone.fromJson(e as Map<String, dynamic>))
        .toList();
    _cachedZones = list;
    return list;
  });

  @override
  Future<PageResult<ClubZone>> find(ZoneQuery q) => guard(() async {
    final list = await findAllActive();
    return PageResult(items: list, page: 1, size: list.length, total: list.length);
  });

  @override
  Future<ClubZone?> findById(int id) async => null;

  @override
  Future<void> softDelete(int id) => guard(() async {
    await _dio.delete('/zones/$id');
    _cachedZones = null; // Сброс кэша
  });

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> hardDelete(int id) async {}
}