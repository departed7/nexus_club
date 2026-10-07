import 'package:flutter/material.dart';
import '../models/club_zone.dart';
import '../models/page_result.dart';
import '../models/zone_query.dart';
import '../repositories/zone_repository.dart';

enum ZoneLoadStatus { idle, loading, success, error }

class ZoneListNotifier extends ChangeNotifier {
  final ZoneRepository _repository;

  ZoneListNotifier(this._repository);

  ZoneQuery _query = const ZoneQuery();
  PageResult<ClubZone> _result = PageResult.empty();
  ZoneLoadStatus _status = ZoneLoadStatus.idle;
  String? _error;

  ZoneQuery get query => _query;
  PageResult<ClubZone> get result => _result;
  ZoneLoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    _status = ZoneLoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = ZoneLoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить зоны: $e';
      _status = ZoneLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(ZoneQuery next) async {
    _query = next;
    await load();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }
}