import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';
import 'computer_repository.dart';

class InMemoryComputerRepository implements ComputerRepository {
  static const _storageKey = 'nexus_computers_v2';
  final SharedPreferences? _prefs;
  List<Computer> _computers = [];

  static final List<Computer> _initialSeed = [
    const Computer(id: 1, name: 'NEXUS-01', gpu: 'RTX 4060', cpu: 'Core i5-13400F', ramGb: 16, zoneId: 1, gameIds: [1, 2, 3], hourlyRate: 150.0, isVip: false, ipAddress: '192.168.1.101'),
    const Computer(id: 2, name: 'NEXUS-02', gpu: 'RTX 4060', cpu: 'Core i5-13400F', ramGb: 16, zoneId: 1, gameIds: [1, 2], hourlyRate: 150.0, isVip: false, ipAddress: '192.168.1.102'),
    const Computer(id: 3, name: 'NEXUS-03', gpu: 'RTX 4060 Ti', cpu: 'Core i5-13600K', ramGb: 32, zoneId: 1, gameIds: [1, 3, 4], hourlyRate: 180.0, isVip: false, ipAddress: '192.168.1.103'),
    const Computer(id: 4, name: 'NEXUS-04', gpu: 'RTX 4060 Ti', cpu: 'Core i5-13600K', ramGb: 32, zoneId: 1, gameIds: [2, 4], hourlyRate: 180.0, isVip: false, ipAddress: '192.168.1.104'),
    const Computer(id: 5, name: 'NEXUS-05', gpu: 'RTX 4070', cpu: 'Ryzen 7 7700X', ramGb: 32, zoneId: 1, gameIds: [1, 2, 5], hourlyRate: 200.0, isVip: false, ipAddress: '192.168.1.105'),
    const Computer(id: 6, name: 'NEXUS-06', gpu: 'RTX 4070', cpu: 'Ryzen 7 7700X', ramGb: 32, zoneId: 1, gameIds: [3, 5], hourlyRate: 200.0, isVip: false, ipAddress: '192.168.1.106'),
    const Computer(id: 7, name: 'VIP-NEON-01', gpu: 'RTX 4080 Super', cpu: 'Core i7-14700K', ramGb: 32, zoneId: 2, gameIds: [1, 2, 3, 4, 5], hourlyRate: 350.0, isVip: true, ipAddress: '192.168.1.107'),
    const Computer(id: 8, name: 'VIP-NEON-02', gpu: 'RTX 4080 Super', cpu: 'Core i7-14700K', ramGb: 32, zoneId: 2, gameIds: [1, 2, 3, 4, 5], hourlyRate: 350.0, isVip: true, ipAddress: '192.168.1.108'),
    const Computer(id: 9, name: 'VIP-NEON-03', gpu: 'RTX 4090', cpu: 'Core i9-14900KF', ramGb: 64, zoneId: 2, gameIds: [1, 2, 3, 4, 5], hourlyRate: 450.0, isVip: true, ipAddress: '192.168.1.109'),
    const Computer(id: 10, name: 'VIP-NEON-04', gpu: 'RTX 4090', cpu: 'Core i9-14900KF', ramGb: 64, zoneId: 2, gameIds: [1, 2, 3, 4, 5], hourlyRate: 450.0, isVip: true, ipAddress: '192.168.1.110'),
    const Computer(id: 11, name: 'BOOTCAMP-A1', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, gameIds: [1, 2], hourlyRate: 280.0, isVip: false, ipAddress: '192.168.1.111'),
    const Computer(id: 12, name: 'BOOTCAMP-A2', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, gameIds: [1, 2], hourlyRate: 280.0, isVip: false, ipAddress: '192.168.1.112'),
    const Computer(id: 13, name: 'BOOTCAMP-A3', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, gameIds: [1, 2], hourlyRate: 280.0, isVip: false, ipAddress: '192.168.1.113'),
    const Computer(id: 14, name: 'BOOTCAMP-A4', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, gameIds: [1, 2], hourlyRate: 280.0, isVip: false, ipAddress: '192.168.1.114'),
    const Computer(id: 15, name: 'BOOTCAMP-A5', gpu: 'RTX 4070 Ti', cpu: 'Ryzen 7 7800X3D', ramGb: 32, zoneId: 3, gameIds: [1, 2], hourlyRate: 280.0, isVip: false, ipAddress: '192.168.1.115'),
    const Computer(id: 16, name: 'STREAM-PRO', gpu: 'RTX 4090 OC', cpu: 'Ryzen 9 7950X', ramGb: 64, zoneId: 4, gameIds: [1, 2, 3, 4, 5], hourlyRate: 500.0, isVip: true, ipAddress: '192.168.1.116'),
    const Computer(id: 17, name: 'STAGE-01', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, gameIds: [1, 2], hourlyRate: 320.0, isVip: true, ipAddress: '192.168.1.117'),
    const Computer(id: 18, name: 'STAGE-02', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, gameIds: [1, 2], hourlyRate: 320.0, isVip: true, ipAddress: '192.168.1.118'),
    const Computer(id: 19, name: 'STAGE-03', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, gameIds: [1, 2], hourlyRate: 320.0, isVip: true, ipAddress: '192.168.1.119'),
    const Computer(id: 20, name: 'STAGE-04', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, gameIds: [1, 2], hourlyRate: 320.0, isVip: true, ipAddress: '192.168.1.120'),
    const Computer(id: 21, name: 'STAGE-05', gpu: 'RTX 4080', cpu: 'Core i9-13900K', ramGb: 32, zoneId: 7, gameIds: [1, 2], hourlyRate: 320.0, isVip: true, ipAddress: '192.168.1.121'),
    const Computer(id: 22, name: 'RESERVE-PC', gpu: 'RTX 3060', cpu: 'Core i5-12400', ramGb: 16, zoneId: 1, gameIds: [1], hourlyRate: 120.0, isVip: false, ipAddress: '192.168.1.122'),
  ];

  InMemoryComputerRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    final prefs = _prefs;
    if (prefs == null) {
      _computers = List.from(_initialSeed);
      return;
    }
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      _computers = List.from(_initialSeed);
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _computers = list.map((e) => Computer.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _computers = List.from(_initialSeed);
      _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_storageKey, jsonEncode(_computers.map((b) => b.toJson()).toList()));
  }

  @override
  Future<PageResult<Computer>> find(ComputerQuery query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var rows = _computers.where((c) => query.includeDeleted || !c.isDeleted).toList();

    if (query.search.trim().isNotEmpty) {
      final needle = query.search.trim().toLowerCase();
      rows = rows.where((c) =>
          c.name.toLowerCase().contains(needle) ||
          c.gpu.toLowerCase().contains(needle) ||
          c.cpu.toLowerCase().contains(needle) ||
          c.ipAddress.contains(needle)).toList();
    }

    if (query.zoneId != null) {
      rows = rows.where((c) => c.zoneId == query.zoneId).toList();
    }
    if (query.isVip != null) {
      rows = rows.where((c) => c.isVip == query.isVip).toList();
    }

    rows.sort((a, b) {
      final res = switch (query.sortField) {
        'rate' => a.hourlyRate.compareTo(b.hourlyRate),
        'gpu' => a.gpu.compareTo(b.gpu),
        'ram' => a.ramGb.compareTo(b.ramGb),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return query.sortAscending ? res : -res;
    });

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
  Future<void> create(Computer computer) async {
    final newId = _computers.isEmpty ? 1 : (_computers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);
    final newComputer = computer.copyWith();
    _computers.add(Computer(
      id: newId,
      name: newComputer.name,
      gpu: newComputer.gpu,
      cpu: newComputer.cpu,
      ramGb: newComputer.ramGb,
      zoneId: newComputer.zoneId,
      gameIds: newComputer.gameIds,
      hourlyRate: newComputer.hourlyRate,
      isVip: newComputer.isVip,
      ipAddress: newComputer.ipAddress,
    ));
    await _persist();
  }

  @override
  Future<void> update(Computer computer) async {
    final i = _computers.indexWhere((c) => c.id == computer.id);
    if (i != -1) {
      _computers[i] = computer;
      await _persist();
    }
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _computers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _computers[i] = _computers[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _computers.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _computers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _computers[i] = _computers[i].copyWith(clearDeletedAt: true);
      await _persist();
    }
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
    await _persist();
    return count;
  }

  @override
  Future<bool> isIpUnique(String ip, {int? excludeId}) async {
    return !_computers.any((c) => c.ipAddress.trim() == ip.trim() && c.id != excludeId);
  }

  @override
  Future<int> countByZoneId(int zoneId) async {
    return _computers.where((c) => c.zoneId == zoneId && !c.isDeleted).length;
  }
}