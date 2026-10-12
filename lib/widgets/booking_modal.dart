import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_notifier.dart';

void showBookingModal(BuildContext context, {String? preselectedPc}) {
  showDialog(
    context: context,
    builder: (ctx) => _BookingDialog(preselectedPc: preselectedPc),
  );
}

class _BookingDialog extends StatefulWidget {
  final String? preselectedPc;
  const _BookingDialog({this.preselectedPc});

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  String _selectedPc = 'NEXUS-01 (Standard)';
  String _selectedTariff = '3 часа';
  int _hours = 3;
  double _baseHourlyRate = 150.0;
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _pcs = const [
    {'name': 'NEXUS-01 (Standard)', 'rate': 150.0},
    {'name': 'NEXUS-05 (Standard)', 'rate': 180.0},
    {'name': 'VIP-NEON-01 (RTX 4080)', 'rate': 350.0},
    {'name': 'VIP-NEON-03 (RTX 4090)', 'rate': 450.0},
    {'name': 'BOOTCAMP-A1 (360Hz)', 'rate': 280.0},
  ];

  final List<Map<String, dynamic>> _tariffs = const [
    {'name': '1 час', 'hours': 1, 'multiplier': 1.0},
    {'name': '3 часа', 'hours': 3, 'multiplier': 0.9},
    {'name': '5 часов', 'hours': 5, 'multiplier': 0.8},
    {'name': 'Ночной (8ч)', 'hours': 8, 'multiplier': 0.65},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedPc != null && _pcs.any((p) => p['name'] == widget.preselectedPc)) {
      _selectedPc = widget.preselectedPc!;
    } else {
      _selectedPc = _pcs.first['name'] as String;
    }
    _selectedTariff = '3 часа';
    _updateRate();
  }

  void _updateRate() {
    final pc = _pcs.firstWhere((p) => p['name'] == _selectedPc, orElse: () => _pcs.first);
    _baseHourlyRate = pc['rate'] as double;
  }

  double _calculateTotal(int userDiscount) {
    final tariff = _tariffs.firstWhere((t) => t['name'] == _selectedTariff, orElse: () => _tariffs[1]);
    final multiplier = tariff['multiplier'] as double;
    final gross = _baseHourlyRate * _hours * multiplier;
    final discountAmount = gross * (userDiscount / 100.0);
    return gross - discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;
    final discount = (user != null && user.role.name == 'gamer') ? 10 : 0;
    final totalCost = _calculateTotal(discount);

    // Защита от несовпадения значений в выпадающих списках
    final validPcs = _pcs.map((p) => p['name'] as String).toList();
    if (!validPcs.contains(_selectedPc)) {
      _selectedPc = validPcs.first;
    }

    final validTariffs = _tariffs.map((t) => t['name'] as String).toList();
    if (!validTariffs.contains(_selectedTariff)) {
      _selectedTariff = validTariffs[1]; // '3 часа'
    }

    return Dialog(
      backgroundColor: const Color(0xFF0F1527),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1E2842)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _isSuccess
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: Color(0x2610B981), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 18),
                    const Text('СЕТАП ЗАБРОНИРОВАН!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    Text(
                      'Бронь #NX-${DateTime.now().millisecondsSinceEpoch % 10000} успешно создана для ${user?.username ?? "Гостя"}.\nПК: $_selectedPc\nСумма к оплате: ${totalCost.toInt()} ₽',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5500)),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отлично', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.desktop_windows_rounded, color: Color(0xFFFF5500), size: 22),
                            SizedBox(width: 10),
                            Text('БРОНИРОВАНИЕ ПК', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('ВЫБЕРИТЕ КОМПЬЮТЕР:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080C16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E2842)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPc,
                          dropdownColor: const Color(0xFF0F1527),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          isExpanded: true,
                          items: validPcs.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPc = val;
                                _updateRate();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('ТАРИФНЫЙ ПАКЕТ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080C16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E2842)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTariff,
                          dropdownColor: const Color(0xFF0F1527),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          isExpanded: true,
                          items: validTariffs.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTariff = val;
                                final t = _tariffs.firstWhere((x) => x['name'] == val);
                                _hours = t['hours'] as int;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141C33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2842)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Базовая ставка:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              Text('${_baseHourlyRate.toInt()} ₽/ч', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Клубная скидка игрока:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              Text('$discount%', style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 18, color: Color(0xFF1E2842)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ИТОГО К ОПЛАТЕ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                              Text('${totalCost.toInt()} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFF5500))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5500),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => setState(() => _isSuccess = true),
                      child: const Text('ПОДТВЕРДИТЬ БРОНИРОВАНИЕ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}