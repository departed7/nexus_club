import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../widgets/nexus_brand_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _expandedFaq;
  int? _hoveredCard; // Индекс карточки при наведении

  final _faqs = [
    {
      'q': 'Как забронировать игровой компьютер?',
      'a': 'Перейдите в раздел «Компьютеры», выберите свободный сетап с подходящей видеокартой и оформите бронь на удобное время.'
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
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final role = user?.role ?? Role.gamer;

    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1222),
        elevation: 0,
        title: const NexusBrandLogo(fontSize: 19),
        actions: [
          TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Главная', style: TextStyle(color: Color(0xFFFF5500), fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => context.go('/computers'), child: const Text('Компьютеры', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => context.go('/zones'), child: const Text('Цены и Залы', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => context.go('/members'), child: const Text('Клиенты', style: TextStyle(color: Colors.white))),
          if (auth.has(Role.admin))
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
              onPressed: () => context.go('/computers'),
              child: const Text('Забронировать', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Выход',
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF94A3B8)),
            onPressed: () => auth.logout(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HERO-СЕКЦИЯ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'сеть киберспортивных клубов\nнового поколения',
                                  style: TextStyle(
                                    fontSize: 34,
                                    height: 1.2,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      'КИБЕР',
                                      style: TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                        color: const Color(0xFFFF5500),
                                        shadows: [
                                          Shadow(color: const Color(0x66FF5500), blurRadius: 24),
                                        ],
                                      ),
                                    ),
                                    const Text(
                                      'NEXUS',
                                      style: TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          _buildHeroStat('22+', 'мощных игровых ПК\nв арене'),
                          const SizedBox(width: 48),
                          _buildHeroStat('88%', 'клиентов возвращаются\nвновь каждую неделю'),
                          const SizedBox(width: 48),
                          _buildHeroStat('3', 'премиальных зала:\nStandard, VIP, Bootcamp'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. БЛОК ТАРИФОВ И ЗОН С HOVER-ЭФФЕКТАМИ
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ТАРИФЫ И ИГРОВЫЕ ПРОСТРАНСТВА',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInteractiveCard(
                              index: 1,
                              badge: 'STANDARD',
                              title: 'Основной зал с NVIDIA RTX 4060Ti для соло и команд',
                              specs: 'RTX 4060Ti • i5-13400F • 16GB • 165Hz',
                              rates: [
                                {'time': '08:00–17:00', 'dur': '1 час', 'price': '150 ₽'},
                                {'time': '08:00–16:00', 'dur': '3 часа', 'price': '400 ₽'},
                                {'time': '08:00–14:00', 'dur': '5 часов', 'price': '600 ₽'},
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
                              rates: [
                                {'time': '08:00–17:00', 'dur': '1 час', 'price': '350 ₽'},
                                {'time': '08:00–16:00', 'dur': '3 часа', 'price': '900 ₽'},
                                {'time': '08:00–14:00', 'dur': '5 часов', 'price': '1400 ₽'},
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
                              rates: [
                                {'time': '08:00–17:00', 'dur': '1 час', 'price': '280 ₽'},
                                {'time': '08:00–16:00', 'dur': '3 часа', 'price': '800 ₽'},
                                {'time': '08:00–14:00', 'dur': '5 часов', 'price': '1200 ₽'},
                                {'time': '22:00–08:00', 'dur': 'Ночь', 'price': '1800 ₽'},
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. БЛОК ИГР С ПОСТЕРАМИ (КАК В КИБЕРPRIDE)
            Container(
              color: const Color(0xFF0B101E),
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ИГРЫ АРЕНЫ',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                            ),
                            Text('Более 400 предустановленных тайтлов на скоростных SSD', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildGamePoster(
                              'DOTA 2',
                              'MOBA • Valve',
                              'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota2_social.jpg',
                            ),
                            const SizedBox(width: 16),
                            _buildGamePoster(
                              'COUNTER-STRIKE 2',
                              'Тактический шутер',
                              'https://cdn.cloudflare.steamstatic.com/apps/csgo/images/csgo_react/social/cs2.jpg',
                            ),
                            const SizedBox(width: 16),
                            _buildGamePoster(
                              'PUBG: BATTLEGROUNDS',
                              'Battle Royale',
                              'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600&q=80',
                            ),
                            const SizedBox(width: 16),
                            _buildGamePoster(
                              'CYBERPUNK 2077',
                              'Ray Tracing Overdrive',
                              'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600&q=80',
                            ),
                          ],
                        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
                  child: Column(
                    children: [
                      const Text(
                        'ВОПРОС — ОТВЕТ',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faqs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final isExpanded = _expandedFaq == i;
                          return InkWell(
                            onTap: () => setState(() => _expandedFaq = isExpanded ? null : i),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101728),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: isExpanded ? const Color(0xFFFF5500) : const Color(0xFF1B253D)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_faqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1C2740)),
                                        child: Icon(isExpanded ? Icons.close : Icons.add, size: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 12),
                                    Text(_faqs[i]['a']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5)),
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
        Text(num, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
      ],
    );
  }

  // Интерактивная карточка тарифов с Hover-эффектами
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
                  ? [
                      const BoxShadow(
                        color: Color(0x26F59E0B),
                        blurRadius: 16,
                      )
                    ]
                  : []),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  badge,
                  style: TextStyle(
                    fontSize: 22,
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
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(specs, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            const Divider(height: 32, color: Color(0xFF1C2642)),

            ...rates.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['time']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace')),
                      Text(r['dur']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text(r['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF5500))),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: isHovered || isVip ? const Color(0xFFFF5500) : const Color(0xFF1E2A47),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => context.go('/computers'),
                child: const Text('Выбрать сетап', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Постер игры с реальной обложкой
  Widget _buildGamePoster(String title, String genre, String imageUrl) {
    return Expanded(
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2B4B)),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 2),
            Text(genre, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}