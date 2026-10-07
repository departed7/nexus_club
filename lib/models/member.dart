class LoyaltyCard {
  final String cardNumber;
  final int discountPercent;
  final double bonusBalance;

  const LoyaltyCard({
    required this.cardNumber,
    required this.discountPercent,
    required this.bonusBalance,
  });

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'discountPercent': discountPercent,
        'bonusBalance': bonusBalance,
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        cardNumber: json['cardNumber'] as String? ?? 'NEXUS-0000',
        discountPercent: json['discountPercent'] as int? ?? 5,
        bonusBalance: (json['bonusBalance'] as num?)?.toDouble() ?? 0.0,
      );
}

class Member {
  final int id;
  final String nickname;
  final String email;
  final String phone;
  final LoyaltyCard card; // Связь Один к одному
  final DateTime? deletedAt;

  const Member({
    required this.id,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Member copyWith({
    String? nickname,
    String? email,
    String? phone,
    LoyaltyCard? card,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Member(
      id: id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'email': email,
        'phone': phone,
        'card': card.toJson(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as int,
        nickname: json['nickname'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        card: json['card'] != null
            ? LoyaltyCard.fromJson(json['card'] as Map<String, dynamic>)
            : const LoyaltyCard(cardNumber: 'NEXUS-0000', discountPercent: 5, bonusBalance: 0),
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
      );
}