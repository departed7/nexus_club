import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';
import 'computer_repository.dart';

class InMemoryComputerRepository implements ComputerRepository {
  final List<Computer> _computers = [
    const Computer(id: 1, name: 'NEXUS-01', gpu: 'RTX 4060', cpu: 'Core i5-13400F', ramGb: 16, zoneId: 1, hourlyRate: 150.0, isVip: false),
    const Computer(id: 2, name: 'NEXUS-02', gpu: 'RTX 4060', cpu: 'Core i5-13400F', ramGb: 16, zoneId: 1, hourlyRate: 150.0, isVip: false),
    const Computer(id: 3, name: 'NEXUS-03', gpu: 'RTX 4060 Ti', cpu: 'Core i5-13600K', ramGb: 32, zoneId: 1, hourlyRate: 180.0, isVip: false),
    const Computer(id: 4, name: 'NEXUS-04', gpu: 'RTX 4060 Ti', cpu: 'Core i5-13600K', ramGb: 32, zoneId: 1, hourlyRate: 180.0, isVip: false),
    const Computer(id: 5, name: 'NEXUS-05', gpu: 'RTX 4070', cpu: 'Ryzen 7 7700X', ramGb: 32, zoneId: 1, hourlyRate: 200.0, isVip: false),
    const Computer(id: 6, name: 'NEXUS-06', gpu: 'RTX 4070', cpu: 'Ryzen 7 7700X', ramGb: 32, zoneId: 1, hourlyRate: 200.0, isVip: false),
    const Computer(id: 7, name: 'VIP-NEON-01', gpu: 'RTX 4080 Super', cpu: 'Core i7-14700K', ramGb: 32, zoneId: 2, hourlyRate: 350.0, isVip: true),
    const Computer(id: 8, name: 'VIP-NEON-02', gpu: 'RTX 4080 Super', cpu: 'Core i7-14700K', ramGb: 32, zoneId: 2, hourlyRate: 350.0, isVip: true),
    const Computer(id: 9, name: 'VIP-NEON-03', gpu: 'RTX 4090', cpu: 'Core i9-14900KF', ramGb: 64, zoneId: 2, hourlyRate: 450.0, isVip: true),
    const Computer(id: 10, name: 'VIP-NEON-04', gpu: 'RTX 4090', cpu: 'Core i9-14900KF', ramGb: 64, zoneId: 2, hourlyRate: 450.0, isVip: true),
    const Computer(id: 11, name: 'BOOTCAMP-A1', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, hourlyRate: 280.0, isVip: false),
    const Computer(id: 12, name: 'BOOTCAMP-A2', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, hourlyRate: 280.0, isVip: false),
    const Computer(id: 13, name: 'BOOTCAMP-A3', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, hourlyRate: 280.0, isVip: false),
    const Computer(id: 14, name: 'BOOTCAMP-A4', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, hourlyRate: 280.0, isVip: false),
    const Computer(id: 15, name: 'BOOTCAMP-A5', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, hourlyRate: 280.0, isVip: false),
    const Computer(id: 16, name: 'STREAM-PRO', gpu: 'RTX 4090 OC', cpu: 'Ryzen 9 7950X', ramGb: 64, zoneId: 4, hourlyRate: 500.0, isVip: true),
    const Computer(id: 17, name: 'STAGE-01', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, hourlyRate: 320.0, isVip: true),
    const Computer(id: 18, name: 'STAGE-02', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, hourlyRate: 320.0, isVip: true),
    const Computer(id: 19, name: 'STAGE-03', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, hourlyRate: 320.0, isVip: true),
    const Computer(id: 20, name: 'STAGE-04', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, hourlyRate: 320.0, isVip: true),
    const Computer(id: 21, name: 'STAGE-05', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, hourlyRate: 320.0, isVip: true),
    const Computer(id: 22, name: 'RESERVE-PC', gpu: 'RTX 3060', cpu: 'Core i5-12400', ramGb: 16, zoneId: 1, hourlyRate: 120.0, isVip: false),
  ];

  @override
  Future<PageResult<Computer>> find(ComputerQuery query) async {
    // Имитация небольшой задержки для спиннера загрузки
    await Future.delayed(const Duration(milliseconds: 200));

    var rows = _computers.where((c) => query.includeDeleted || !c.isDeleted).toList();

    // 1. Поиск по названию, видеокарте или процессору (Критерий 8)
    if (query.search.trim().isNotEmpty) {
      final needle = query.search.trim().toLowerCase();
      rows = rows.where((c) =>
          c.name.toLowerCase().contains(needle) ||
          c.gpu.toLowerCase().contains(needle) ||
          c.cpu.toLowerCase().contains(needle)).toList();
    }

    // 2. Фильтрация по 3+ критериям (Критерий 9)
    if (query.zoneId != null) {
      rows = rows.where((c) => c.zoneId == query.zoneId).toList();
    }
    if (query.minRate != null) {
      rows = rows.where((c) => c.hourlyRate >= query.minRate!).toList();
    }
    if (query.maxRate != null) {
      rows = rows.where((c) => c.hourlyRate <= query.maxRate!).toList();
    }
    if (query.isVip != null) {
      rows = rows.where((c) => c.isVip == query.isVip).toList();
    }

    // 3. Сортировка по колонкам (Критерий 14)
    rows.sort((a, b) {
      final res = switch (query.sortField) {
        'rate' => a.hourlyRate.compareTo(b.hourlyRate),
        'gpu' => a.gpu.compareTo(b.gpu),
        'ram' => a.ramGb.compareTo(b.ramGb),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return query.sortAscending ? res : -res;
    });

    // 4. Пагинация (Критерий 13)
    final total = rows.length;
    final from = (query.page - 1) * query.size;
    final to = (from + query.size) > total ? total : (from + query.size);
    final items = from >= total ? <Computer>[] : rows.sublist(from, to);

    return PageResult(items: items, page: query.page, size: query.size, total: total);
  }

  @override
  Future<Computer?> findById(int id) async {
    try {
      return _computers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _computers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _computers[i] = _computers[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> restore(int id) async {
    final i = _computers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _computers[i] = _computers[i].copyWith(clearDeletedAt: true);
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _computers.removeWhere((c) => c.id == id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _computers.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _computers[i] = _computers[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}