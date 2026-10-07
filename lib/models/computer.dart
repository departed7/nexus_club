class Computer {
  final int id;
  final String name;       // например "PC-01 VIP"
  final String gpu;        // RTX 4080, RTX 4090
  final String cpu;        // Core i7, Ryzen 7
  final int ramGb;         // 32, 64
  final int zoneId;        // ссылка на ClubZone
  final double hourlyRate; // цена за час в рублях
  final bool isVip;        // VIP статус
  final DateTime? deletedAt;

  const Computer({
    required this.id,
    required this.name,
    required this.gpu,
    required this.cpu,
    required this.ramGb,
    required this.zoneId,
    required this.hourlyRate,
    required this.isVip,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Computer copyWith({
    String? name,
    String? gpu,
    String? cpu,
    int? ramGb,
    int? zoneId,
    double? hourlyRate,
    bool? isVip,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Computer(
      id: id,
      name: name ?? this.name,
      gpu: gpu ?? this.gpu,
      cpu: cpu ?? this.cpu,
      ramGb: ramGb ?? this.ramGb,
      zoneId: zoneId ?? this.zoneId,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isVip: isVip ?? this.isVip,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}