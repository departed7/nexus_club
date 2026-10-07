import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';

abstract interface class ComputerRepository {
  Future<PageResult<Computer>> find(ComputerQuery query);
  Future<Computer?> findById(int id);
  Future<void> create(Computer computer);
  Future<void> update(Computer computer);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
  // Проверка уникальности IP-адреса (Критерий 12 на оценку «4»)
  Future<bool> isIpUnique(String ip, {int? excludeId});
  // Проверка связанных ПК перед удалением Зоны (Критерий 13)
  Future<int> countByZoneId(int zoneId);
}