import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../repositories/member_repository.dart';
import '../widgets/entity_table.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Member> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await context.read<MemberRepository>().findAllActive();
    if (mounted) {
      setState(() {
        _members = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Постоянные клиенты (Клубные карты 1:1)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/computers'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF10121A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF232838)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => context.go('/computers'),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Компьютеры', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/zones'),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Зоны клуба', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Клиенты', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  EntityTable<Member>(
                    items: _members,
                    idOf: (m) => m.id,
                    columns: [
                      TableColumnSpec<Member>(
                        label: 'Никнейм',
                        build: (m) => Text(m.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TableColumnSpec<Member>(
                        label: 'Email (Уникальный)',
                        build: (m) => Text(m.email, style: const TextStyle(color: Color(0xFF38BDF8))),
                      ),
                      TableColumnSpec<Member>(
                        label: 'Телефон',
                        build: (m) => Text(m.phone, style: const TextStyle(color: Color(0xFF94A3B8))),
                      ),
                      TableColumnSpec<Member>(
                        label: 'Номер карты (1:1)',
                        build: (m) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2230),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(m.card.cardNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableColumnSpec<Member>(
                        label: 'Скидка',
                        numeric: true,
                        build: (m) => Text('${m.card.discountPercent}%', style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                      ),
                      TableColumnSpec<Member>(
                        label: 'Бонусный баланс',
                        numeric: true,
                        build: (m) => Text('${m.card.bonusBalance.toInt()} ₽', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}