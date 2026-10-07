import 'dart:async';
import 'package:flutter/material.dart';
import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/page_result.dart';
import '../repositories/computer_repository.dart';

enum LoadStatus { idle, loading, success, error }

class ComputerListNotifier extends ChangeNotifier {
  final ComputerRepository _repository;

  ComputerListNotifier(this._repository);

  ComputerQuery _query = const ComputerQuery();
  PageResult<Computer> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  Timer? _debounceTimer;

  ComputerQuery get query => _query;
  PageResult<Computer> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список ПК: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(ComputerQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  // Задержка 300 мс при вводе в поиск (Критерий 17 на "5")
  void setSearchDebounced(String search, VoidCallback onApplied) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      applyQuery(_query.copyWith(search: search));
      onApplied();
    });
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  void selectAllOnPage() {
    if (_selected.length == _result.items.length) {
      _selected.clear();
    } else {
      _selected.clear();
      _selected.addAll(_result.items.map((e) => e.id));
    }
    notifyListeners();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    _selected.remove(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }

  Future<int> deleteSelected() async {
    final count = await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
    return count;
  }
}