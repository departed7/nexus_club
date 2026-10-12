import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../widgets/nexus_brand_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Выбранный аватар и никнейм
  String _currentAvatar = '🎮';
  late TextEditingController _nickController;
  bool _isEditingNick = false;

  final List<String> _avatars = ['🎮', '⚡', '👑', '🐉', '🤖', '🔥', '🥷', '🦁'];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthNotifier>();
    _nickController = TextEditingController(text: auth.user?.username ?? 'Gamer');
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1527),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E2842)),
        ),
        title: const Text('Выберите аватар профиля', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _avatars.map((emoji) {
            final isSelected = emoji == _currentAvatar;
            return InkWell(
              onTap: () {
                setState(() => _currentAvatar = emoji);
                Navigator.of(ctx).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5500) : const Color(0xFF141D33),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFFFF5500) : const Color(0xFF24304A)),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final role = user?.role ?? Role.gamer;

    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1222),
        elevation: 0,
        title: const NexusBrandLogo(fontSize: 18, subtitle: 'ЛИЧНЫЙ ПРОФИЛЬ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ВЕРХНИЙ БЛОК ПРОФИЛЯ С АВАТАРОМ И РЕДАКТИРОВАНИЕМ НИКА
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1527),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E2842)),
                  ),
                  child: Row(
                    children: [
                      // Кликабельный аватар
                      InkWell(
                        onTap: _showAvatarPicker,
                        borderRadius: BorderRadius.circular(40),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF161F36),
                                border: Border.all(color: const Color(0xFFFF5500), width: 2),
                              ),
                              child: Center(child: Text(_currentAvatar, style: const TextStyle(fontSize: 38))),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF5500)),
                                child: const Icon(Icons.edit, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Редактирование никнейма
                            if (_isEditingNick)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 38,
                                    child: TextField(
                                      controller: _nickController,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Color(0xFF10B981), size: 20),
                                    onPressed: () => setState(() => _isEditingNick = false),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Text(
                                    _nickController.text,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  IconButton(
                                    tooltip: 'Изменить никнейм',
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF94A3B8)),
                                    onPressed: () => setState(() => _isEditingNick = true),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(user?.email ?? 'gamer@nexus.club', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: role == Role.admin ? const Color(0x33FBBF24) : const Color(0x26FF5500),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: role == Role.admin ? const Color(0xFFFBBF24) : const Color(0xFFFF5500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. ЦИФРОВАЯ КАРТА ЛОЯЛЬНОСТИ (1:1)
                Container(
                  height: 190,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2848), Color(0xFF0F1527)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x66FF5500), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NexusBrandLogo(fontSize: 16),
                          Text('NEXUS LOYALTY CARD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF5500), letterSpacing: 1.0)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.nfc_rounded, color: Colors.white70, size: 26),
                          const SizedBox(width: 12),
                          Text('NEXUS-00${user?.id ?? 1}-2025', style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.white70, letterSpacing: 2.0)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ВЛАДЕЛЕЦ', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                              Text(_nickController.text.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('КЭШБЭК / СКИДКА', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                              Text(role == Role.admin ? 'VIP 25%' : '15%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF5500))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. СТАТИСТИКА ИГРОКА
                const Text('ИГРОВАЯ СТАТИСТИКА В КЛУБЕ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF94A3B8))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('НАИГРАНО В АРЕНЕ', '148 ч', Icons.timer_outlined, const Color(0xFF10B981)),
                    const SizedBox(width: 14),
                    _buildStatCard('КЛУБНЫЙ РАНГ', 'DIAMOND', Icons.military_tech_outlined, const Color(0xFFFBBF24)),
                    const SizedBox(width: 14),
                    _buildStatCard('БОНУСНЫЙ БАЛАНС', '1 450 ₽', Icons.account_balance_wallet_outlined, const Color(0xFFFF5500)),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. ИСТОРИЯ ПОСЛЕДНИХ СЕССИЙ
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1527),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2842)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ИСТОРИЯ ПОСЕЩЕНИЙ И СЕССИЙ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 14),
                      _buildHistoryRow('Сегодня, 18:30', 'VIP-NEON-03 (RTX 4090)', 'Пакет 3 часа', '900 ₽'),
                      const Divider(color: Color(0xFF1C2642), height: 20),
                      _buildHistoryRow('05 Октября', 'BOOTCAMP-A1 (360Hz)', 'Пакет 5 часов', '1 200 ₽'),
                      const Divider(color: Color(0xFF1C2642), height: 20),
                      _buildHistoryRow('02 Октября', 'NEXUS-01 (Standard)', 'Ночной Non-Stop', '850 ₽'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1527),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2842)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String date, String pc, String tariff, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
            Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF5500))),
            Text(tariff, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }
}