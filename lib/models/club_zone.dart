class ClubZone {
  final int id;
  final String name;
  final String description;
  final double hourlyPrice;
  final DateTime? deletedAt;

  const ClubZone({
    required this.id,
    required this.name,
    required this.description,
    required this.hourlyPrice,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  ClubZone copyWith({
    String? name,
    String? description,
    double? hourlyPrice,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return ClubZone(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}