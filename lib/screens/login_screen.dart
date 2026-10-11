import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth_notifier.dart';
import '../widgets/nexus_brand_logo.dart';

class LoginScreen extends StatefulWidget {
  final String? from;
  const LoginScreen({super.key, this.from});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  void _fillDemo(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthNotifier>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) {
        final target = widget.from != null ? Uri.decodeComponent(widget.from!) : '/dashboard';
        context.go(target);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1527),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E2842)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, offset: const Offset(0, 15)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Левая промо-колонка
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF151D33), Color(0xFF0B101E)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const NexusBrandLogo(fontSize: 22, subtitle: 'СИСТЕМА УПРАВЛЕНИЯ КЛУБОМ'),
                                const SizedBox(height: 36),
                                const Text(
                                  'ТВОЯ АРЕНА.\nТВОИ ПРАВИЛА.',
                                  style: TextStyle(
                                    fontSize: 26,
                                    height: 1.2,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Авторизуйтесь в системе для управления рабочими станциями, бронированиями и клубным профилем.',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                                ),
                                const SizedBox(height: 28),
                                _buildFeature(Icons.speed_rounded, 'Минимальный отклик сети • Пинг до серверов 3–5 мс'),
                                const SizedBox(height: 16),
                                _buildFeature(Icons.monitor_rounded, 'Экраны 280–360Hz в залах VIP и BOOTCAMP'),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12182B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                                  SizedBox(width: 8),
                                  Text('22 компьютера онлайн • 3 зала активны', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Правая колонка с формой
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ВХОД В СИСТЕМУ',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Введите учетные данные для авторизации',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                              const SizedBox(height: 24),

                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E1319),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE11D48)),
                                  ),
                                  child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFB7185), fontSize: 12)),
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Логин или Email',
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFFFF5500), size: 20),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Введите логин' : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF5500), size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF64748B)),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Введите пароль' : null,
                              ),
                              const SizedBox(height: 24),

                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5500),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isLoading ? null : _submit,
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('ВОЙТИ В АРЕНУ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                              ),
                              const SizedBox(height: 14),

                              Center(
                                child: TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: const Text('Создать аккаунт игрока', style: TextStyle(color: Color(0xFFFF5500), fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFF1E2842)),
                              const SizedBox(height: 10),

                              const Text(
                                'БЫСТРЫЙ ДЕМО-ВХОД ДЛЯ ПРОВЕРКИ:',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRoleBtn('Admin', const Color(0xFFFF5500), () => _fillDemo('admin', 'Admin@123')),
                                  const SizedBox(width: 8),
                                  _buildRoleBtn('Operator', const Color(0xFF38BDF8), () => _fillDemo('operator', 'Staff@123')),
                                  const SizedBox(width: 8),
                                  _buildRoleBtn('Gamer', Colors.white, () => _fillDemo('gamer', 'Gamer@123')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF1E2842), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFFFF5500), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildRoleBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141B2D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}