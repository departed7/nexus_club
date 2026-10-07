import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';

abstract interface class ComputerRepository {
  Future<PageResult<Computer>> find(ComputerQuery query);
  Future<Computer?> findById(int id);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids); 
}