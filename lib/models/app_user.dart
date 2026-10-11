import 'role.dart';

class AppUser {
  final int id;
  final String username;
  final String email;
  final Role role;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: Role.fromString(json['role'] as String?),
      );
}