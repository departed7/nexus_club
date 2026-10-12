import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 500,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1FE11D48),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xEF101422),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x66E11D48), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 32,
                        offset: Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Color(0x1AE11D48),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1319),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE11D48)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4DE11D48),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_outlined, size: 48, color: Color(0xFFFB7185)),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1319),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SECURITY VIOLATION // 403',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFFFB7185),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'ДОСТУП ЗАБЛОКИРОВАН',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Уровень привилегий вашей учётной записи недостаточен для просмотра этого закрытого раздела или выполнения данной операции.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF283654)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => context.go('/computers'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('ВЕРНУТЬСЯ В КАТАЛОГ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}