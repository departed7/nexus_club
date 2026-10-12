import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = context.read<Dio>();
      final res = await dio.get('/admin/users');
      final list = (res.data as List).map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) {
        setState(() {
          _users = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  Color _getRoleColor(String role) {
    return switch (role) {
      'admin' => const Color(0xFFFBBF24),
      'operator' => const Color(0xFF38BDF8),
      _ => const Color(0xFF00E599),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1523),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2210),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF785412)),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: Color(0xFFFBBF24)),
            ),
            const SizedBox(width: 12),
            const Text('ПЕРСОНАЛ И ПОЛЬЗОВАТЕЛИ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/computers'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101422),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1E283D)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.security_rounded, color: Color(0xFF00E599), size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Зарегистрировано учётных записей: ${_users.length}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final u = _users[i];
                              final roleColor = _getRoleColor(u.role.name);

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101422),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF1E283D)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0x2638BDF8),
                                      child: Text(
                                        u.username[0].toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: roleColor),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(u.email, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0x1A00E599),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0x4D00E599)),
                                      ),
                                      child: Text(
                                        u.role.label,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: roleColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}