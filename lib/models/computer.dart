class Computer {
  final int id;
  final String name;
  final String gpu;
  final String cpu;
  final int ramGb;
  final int zoneId;         // Многие к одному
  final List<int> gameIds;  // Многие ко многим
  final double hourlyRate;
  final bool isVip;
  final String ipAddress;   // Поле для проверки уникальности
  final DateTime? deletedAt;

  const Computer({
    required this.id,
    required this.name,
    required this.gpu,
    required this.cpu,
    required this.ramGb,
    required this.zoneId,
    this.gameIds = const [],
    required this.hourlyRate,
    required this.isVip,
    required this.ipAddress,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Computer copyWith({
    String? name,
    String? gpu,
    String? cpu,
    int? ramGb,
    int? zoneId,
    List<int>? gameIds,
    double? hourlyRate,
    bool? isVip,
    String? ipAddress,
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
      gameIds: gameIds ?? this.gameIds,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isVip: isVip ?? this.isVip,
      ipAddress: ipAddress ?? this.ipAddress,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gpu': gpu,
        'cpu': cpu,
        'ramGb': ramGb,
        'zoneId': zoneId,
        'gameIds': gameIds,
        'hourlyRate': hourlyRate,
        'isVip': isVip,
        'ipAddress': ipAddress,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Computer.fromJson(Map<String, dynamic> json) => Computer(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        gpu: json['gpu'] as String? ?? '',
        cpu: json['cpu'] as String? ?? '',
        ramGb: json['ramGb'] as int? ?? 16,
        zoneId: json['zoneId'] as int? ?? 1,
        gameIds: (json['gameIds'] as List?)?.cast<int>() ?? const [],
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 100.0,
        isVip: json['isVip'] as bool? ?? false,
        ipAddress: json['ipAddress'] as String? ?? '192.168.1.1',
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
      );
}