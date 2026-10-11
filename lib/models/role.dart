enum Role {
  gamer(10, 'Игрок'),
  operator(20, 'Оператор зала'),
  admin(30, 'Администратор');

  final int level;
  final String label;
  const Role(this.level, this.label);

  static Role fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'admin' => Role.admin,
      'operator' => Role.operator,
      _ => Role.gamer,
    };
  }
}