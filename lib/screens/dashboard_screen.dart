import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../widgets/nexus_brand_logo.dart';
import '../widgets/booking_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _expandedFaq;
  int? _hoveredCard;

  final _faqs = [
    {
      'q': 'Как забронировать игровой компьютер?',
      'a': 'Нажмите кнопку «Забронировать» в шапке или выберите нужный зал ниже — откроется форма с выбором сетапа, тарифа и автоматическим расчетом стоимости с учетом вашей клубной скидки.'
    },
    {
      'q': 'Какое железо установлено в залах VIP и BOOTCAMP?',
      'a': 'Во всех премиальных зонах установлены видеокарты NVIDIA RTX 4080 Super / RTX 4090, мониторы 280Hz–360Hz и периферия ASUS ROG / ZOWIE.'
    },
    {
      'q': 'Есть ли у вас пакетные тарифы на ночь?',
      'a': 'Да, во всех залах действует специальный ночной тариф «Ночной Non-Stop» с 22:00 до 08:00 по фиксированной выгодной цене.'
    },
    {
      'q': 'Как работает программа лояльности и кэшбэк?',
      'a': 'Каждый зарегистрированный игрок получает клубную карту в личном кабинете. С каждой сессии начисляется кэшбэк до 20% бонусами.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;

    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final role = user?.role ?? Role.gamer;
    final isAdmin = auth.has(Role.admin);

    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1222),
        elevation: 0,
        title: NexusBrandLogo(fontSize: isMobile ? 16 : 19),
        actions: [
          if (!isMobile) ...[
            TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Главная', style: TextStyle(color: Color(0xFFFF5500), fontWeight: FontWeight.bold))),
            TextButton(onPressed: () => context.go('/computers'), child: const Text('Компьютеры', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () => context.go('/zones'), child: const Text('Цены и Залы', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () => context.go('/members'), child: const Text('Клиенты', style: TextStyle(color: Colors.white))),
            if (isAdmin)
              TextButton(onPressed: () => context.go('/admin/users'), child: const Text('Персонал', style: TextStyle(color: Color(0xFFFF5500)))),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => showBookingModal(context),
                child: const Text('Забронировать', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: 'Выход',
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF94A3B8)),
            onPressed: () => auth.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: 0,
              backgroundColor: const Color(0xFF0D1222),
              indicatorColor: const Color(0xFFFF5500),
              onDestinationSelected: (idx) {
                switch (idx) {
                  case 0:
                    context.go('/dashboard');
                  case 1:
                    context.go('/computers');
                  case 2:
                    context.go('/zones');
                  case 3:
                    context.go('/members');
                  case 4:
                    context.go('/admin/users');
                }
              },
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.white), label: 'Главная'),
                const NavigationDestination(icon: Icon(Icons.desktop_windows_outlined), selectedIcon: Icon(Icons.desktop_windows, color: Colors.white), label: 'ПК'),
                const NavigationDestination(icon: Icon(Icons.layers_outlined), selectedIcon: Icon(Icons.layers, color: Colors.white), label: 'Зоны'),
                const NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge, color: Colors.white), label: 'Игроки'),
                if (isAdmin)
                  const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings, color: Colors.white), label: 'Админ'),
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HERO-СЕКЦИЯ
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: isMobile ? 24 : 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172E), Color(0xFF080C16)],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1E2B48)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('СЕССИЯ: ${user?.username.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                              Text(role.label, style: const TextStyle(color: Color(0xFFFF5500), fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMobile ? 'Сеть киберспортивных клубов нового поколения' : 'сеть киберспортивных клубов\nнового поколения',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 34,
                                    height: 1.25,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      Text(
                                        'КИБЕР',
                                        style: TextStyle(
                                          fontSize: isMobile ? 40 : 64,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: const Color(0xFFFF5500),
                                        ),
                                      ),
                                      Text(
                                        'NEXUS',
                                        style: TextStyle(
                                          fontSize: isMobile ? 40 : 64,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isMobile) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131B30),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF1E2B48)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('СЕССИЯ: ${user?.username.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(role.label, style: const TextStyle(color: Color(0xFFFF5500), fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: isMobile ? 24 : 48,
                        runSpacing: 16,
                        children: [
                          _buildHeroStat('22+', 'мощных игровых ПК в сети'),
                          _buildHeroStat('88%', 'клиентов возвращаются вновь'),
                          _buildHeroStat('3', 'премиум зала: Standard, VIP, Bootcamp'),
                        ],
                      ),
                      if (isMobile) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5500),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => showBookingModal(context),
                            child: const Text('ЗАБРОНИРОВАТЬ СЕТАП', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 2. БЛОК ТАРИФОВ
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 24 : 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ТАРИФЫ И ИГРОВЫЕ ПРОСТРАНСТВА',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      if (isMobile) ...[
                        _buildInteractiveCard(
                          index: 1,
                          badge: 'STANDARD',
                          title: 'Основной зал с NVIDIA RTX 4060Ti для соло и команд',
                          specs: 'RTX 4060Ti • i5-13400F • 16GB • 165Hz',
                          rates: const [
                            {'time': '08:00–17:00', 'dur': '1 час', 'price': '150 ₽'},
                            {'time': '08:00–16:00', 'dur': '3 часа', 'price': '400 ₽'},
                            {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '850 ₽'},
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInteractiveCard(
                          index: 2,
                          badge: 'VIP NEON',
                          title: 'Максимальный комфорт, приватность и топовое железо',
                          specs: 'RTX 4080 Super • i7-14700K • 32GB • 280Hz ASUS',
                          isVip: true,
                          rates: const [
                            {'time': '08:00–17:00', 'dur': '1 час', 'price': '350 ₽'},
                            {'time': '08:00–16:00', 'dur': '3 часа', 'price': '900 ₽'},
                            {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '2000 ₽'},
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInteractiveCard(
                          index: 3,
                          badge: 'BOOTCAMP 5v5',
                          title: 'Шумоизолированная комната для кланваров и турниров',
                          specs: 'RTX 4070 Ti • Ryzen 7 7800X3D • 360Hz ZOWIE',
                          rates: const [
                            {'time': '08:00–17:00', 'dur': '1 час', 'price': '280 ₽'},
                            {'time': '08:00–16:00', 'dur': '3 часа', 'price': '800 ₽'},
                            {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '1800 ₽'},
                          ],
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInteractiveCard(
                                index: 1,
                                badge: 'STANDARD',
                                title: 'Основной зал с NVIDIA RTX 4060Ti для соло и команд',
                                specs: 'RTX 4060Ti • i5-13400F • 16GB • 165Hz',
                                rates: const [
                                  {'time': '08:00–17:00', 'dur': '1 час', 'price': '150 ₽'},
                                  {'time': '08:00–16:00', 'dur': '3 часа', 'price': '400 ₽'},
                                  {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '850 ₽'},
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInteractiveCard(
                                index: 2,
                                badge: 'VIP NEON',
                                title: 'Максимальный комфорт, приватность и топовое железо',
                                specs: 'RTX 4080 Super • i7-14700K • 32GB • 280Hz ASUS',
                                isVip: true,
                                rates: const [
                                  {'time': '08:00–17:00', 'dur': '1 час', 'price': '350 ₽'},
                                  {'time': '08:00–16:00', 'dur': '3 часа', 'price': '900 ₽'},
                                  {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '2000 ₽'},
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildInteractiveCard(
                                index: 3,
                                badge: 'BOOTCAMP 5v5',
                                title: 'Шумоизолированная комната для кланваров и турниров',
                                specs: 'RTX 4070 Ti • Ryzen 7 7800X3D • 360Hz ZOWIE',
                                rates: const [
                                  {'time': '08:00–17:00', 'dur': '1 час', 'price': '280 ₽'},
                                  {'time': '08:00–16:00', 'dur': '3 часа', 'price': '800 ₽'},
                                  {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '1800 ₽'},
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 3. БЛОК ИГР (БЕЗ ПЕРЕПОЛНЕНИЯ)
            Container(
              color: const Color(0xFF0B101E),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ИГРЫ АРЕНЫ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text('Предустановлены на скоростных NVMe SSD', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                        const SizedBox(height: 20),
                        if (isMobile) ...[
                          Column(
                            children: [
                              _buildVectorPoster(title: 'DOTA 2', tag: 'MOBA // VALVE', feature: '120+ FPS', icon: Icons.shield_rounded, accentColor: const Color(0xFFE11D48)),
                              const SizedBox(height: 12),
                              _buildVectorPoster(title: 'COUNTER-STRIKE 2', tag: 'ТАКТИЧЕСКИЙ ШУТЕР', feature: '240Hz', icon: Icons.gps_fixed_rounded, accentColor: const Color(0xFFFF5500)),
                              const SizedBox(height: 12),
                              _buildVectorPoster(title: 'VALORANT', tag: 'RIOT ESPORTS', feature: '128 TICK', icon: Icons.bolt_rounded, accentColor: const Color(0xFF38BDF8)),
                              const SizedBox(height: 12),
                              _buildVectorPoster(title: 'CYBERPUNK 2077', tag: 'ACTION RPG', feature: 'RTX ON', icon: Icons.memory_rounded, accentColor: const Color(0xFFFBBF24)),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(child: _buildVectorPoster(title: 'DOTA 2', tag: 'MOBA // VALVE', feature: '120+ FPS', icon: Icons.shield_rounded, accentColor: const Color(0xFFE11D48))),
                              const SizedBox(width: 14),
                              Expanded(child: _buildVectorPoster(title: 'COUNTER-STRIKE 2', tag: 'ТАКТИЧЕСКИЙ ШУТЕР', feature: '240Hz', icon: Icons.gps_fixed_rounded, accentColor: const Color(0xFFFF5500))),
                              const SizedBox(width: 14),
                              Expanded(child: _buildVectorPoster(title: 'VALORANT', tag: 'RIOT ESPORTS', feature: '128 TICK', icon: Icons.bolt_rounded, accentColor: const Color(0xFF38BDF8))),
                              const SizedBox(width: 14),
                              Expanded(child: _buildVectorPoster(title: 'CYBERPUNK 2077', tag: 'ACTION RPG', feature: 'RTX ON', icon: Icons.memory_rounded, accentColor: const Color(0xFFFBBF24))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. FAQ
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
                  child: Column(
                    children: [
                      const Text(
                        'ВОПРОС — ОТВЕТ',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faqs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final isExpanded = _expandedFaq == i;
                          return InkWell(
                            onTap: () => setState(() => _expandedFaq = isExpanded ? null : i),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101728),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isExpanded ? const Color(0xFFFF5500) : const Color(0xFF1B253D)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(_faqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                                      Icon(isExpanded ? Icons.close : Icons.add, size: 18, color: Colors.white),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 10),
                                    Text(_faqs[i]['a']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String num, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(num, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }

  Widget _buildInteractiveCard({
    required int index,
    required String badge,
    required String title,
    required String specs,
    required List<Map<String, String>> rates,
    bool isVip = false,
  }) {
    final isHovered = _hoveredCard == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCard = index),
      onExit: (_) => setState(() => _hoveredCard = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1527),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVip
                ? (isHovered ? const Color(0xFFFF5500) : const Color(0x99F59E0B))
                : (isHovered ? const Color(0xFF38BDF8) : const Color(0xFF1A233D)),
            width: isHovered || isVip ? 1.8 : 1.0,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: isVip ? const Color(0x4DFF5500) : const Color(0x3338BDF8),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : (isVip
                  ? const [
                      BoxShadow(
                        color: Color(0x26F59E0B),
                        blurRadius: 16,
                      )
                    ]
                  : []),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  badge,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isVip ? const Color(0xFFFF5500) : Colors.white,
                  ),
                ),
                if (isVip)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33FF5500),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('TOP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF5500))),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(specs, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            const Divider(height: 24, color: Color(0xFF1C2642)),

            ...rates.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['time']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace')),
                      Text(r['dur']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text(r['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF5500))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: isHovered || isVip ? const Color(0xFFFF5500) : const Color(0xFF1E2A47),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => showBookingModal(context),
                child: const Text('Выбрать сетап', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вертикальная верстка постера (никогда не переполняется)
  Widget _buildVectorPoster({
    required String title,
    required String tag,
    required String feature,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1527),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withAlpha(90)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withAlpha(35),
            const Color(0xFF0F1527),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF080C16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(feature, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}