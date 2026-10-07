class Tariff {
  final int id;
  final String name;
  final int zoneId; // Связь многие к одному с ClubZone
  final int durationHours;
  final double price;
  final DateTime? deletedAt;

  const Tariff({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.durationHours,
    required this.price,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Tariff copyWith({
    String? name,
    int? zoneId,
    int? durationHours,
    double? price,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Tariff(
      id: id,
      name: name ?? this.name,
      zoneId: zoneId ?? this.zoneId,
      durationHours: durationHours ?? this.durationHours,
      price: price ?? this.price,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'zoneId': zoneId,
        'durationHours': durationHours,
        'price': price,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Tariff.fromJson(Map<String, dynamic> json) => Tariff(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        zoneId: json['zoneId'] as int? ?? 1,
        durationHours: json['durationHours'] as int? ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 100.0,
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
      );
}