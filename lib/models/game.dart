class Game {
  final int id;
  final String title;
  final String genre;
  final int storageGb;
  final DateTime? deletedAt;

  const Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.storageGb,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Game copyWith({
    String? title,
    String? genre,
    int? storageGb,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Game(
      id: id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      storageGb: storageGb ?? this.storageGb,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'genre': genre,
        'storageGb': storageGb,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        genre: json['genre'] as String? ?? '',
        storageGb: json['storageGb'] as int? ?? 50,
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
      );
}