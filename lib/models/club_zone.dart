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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'hourlyPrice': hourlyPrice,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory ClubZone.fromJson(Map<String, dynamic> json) => ClubZone(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        hourlyPrice: (json['hourlyPrice'] as num?)?.toDouble() ?? 100.0,
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
      );
}