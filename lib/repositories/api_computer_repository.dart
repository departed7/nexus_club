import 'package:dio/dio.dart';
import '../core/api_exceptions.dart';
import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';
import 'computer_repository.dart';

class ApiComputerRepository implements ComputerRepository {
  final Dio _dio;
  CancelToken? _currentCancelToken;

  ApiComputerRepository(this._dio);

  @override
  Future<PageResult<Computer>> find(ComputerQuery q) => guard(() async {
    _currentCancelToken?.cancel('new_query');
    final token = CancelToken();
    _currentCancelToken = token;

    final response = await _dio.get(
      '/computers',
      cancelToken: token,
      queryParameters: {
        if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
        if (q.zoneId != null) 'zoneId': q.zoneId,
        if (q.isVip != null) 'isVip': q.isVip,
        'sort': q.sortField,
        'desc': (!q.sortAscending).toString(),
        'page': q.page,
        'size': q.size,
        if (q.includeDeleted) 'includeDeleted': 'true',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final itemsList = (data['items'] as List)
        .map((e) => Computer.fromJson(e as Map<String, dynamic>))
        .toList();

    return PageResult(
      items: itemsList,
      page: data['page'] as int? ?? q.page,
      size: data['size'] as int? ?? q.size,
      total: data['total'] as int? ?? 0,
    );
  });

  @override
  Future<Computer?> findById(int id) => guard(() async {
    final response = await _dio.get('/computers/$id');
    return Computer.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> create(Computer computer) => guard(() async {
    await _dio.post('/computers', data: computer.toJson());
  });

  @override
  Future<void> update(Computer computer) => guard(() async {
    await _dio.put('/computers/${computer.id}', data: computer.toJson());
  });

  @override
  Future<void> softDelete(int id) => guard(() async {
    await _dio.delete('/computers/$id');
  });

  @override
  Future<void> hardDelete(int id) => guard(() async {
    await _dio.delete('/computers/$id', queryParameters: {'hard': 'true'});
  });

  @override
  Future<void> restore(int id) => guard(() async {
    await _dio.put('/computers/$id/restore');
  });

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post('/computers/bulk-delete', data: {'ids': ids});
    return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
  });

  @override
  Future<bool> isIpUnique(String ip, {int? excludeId}) async => true;

  @override
  Future<int> countByZoneId(int zoneId) async => 0;
}