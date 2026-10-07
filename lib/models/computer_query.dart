class ComputerQuery {
  final String search;
  final int? zoneId;
  final double? minRate;
  final double? maxRate;
  final bool? isVip;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const ComputerQuery({
    this.search = '',
    this.zoneId,
    this.minRate,
    this.maxRate,
    this.isVip,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  static const _unset = Object();

  ComputerQuery copyWith({
    String? search,
    Object? zoneId = _unset,
    Object? minRate = _unset,
    Object? maxRate = _unset,
    Object? isVip = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return ComputerQuery(
      search: search ?? this.search,
      zoneId: zoneId == _unset ? this.zoneId : zoneId as int?,
      minRate: minRate == _unset ? this.minRate : minRate as double?,
      maxRate: maxRate == _unset ? this.maxRate : maxRate as double?,
      isVip: isVip == _unset ? this.isVip : isVip as bool?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      // При смене фильтров возвращаем на 1 страницу
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}