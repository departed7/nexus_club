import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth_notifier.dart';
import '../widgets/nexus_brand_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _hasMinLength = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _checkPassword(String val) {
    setState(() {
      _hasMinLength = val.length >= 8;
      _hasDigit = RegExp(r'\d').hasMatch(val);
      _hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val);
    });
  }

  Widget _buildCheckBadge(String text, bool valid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: valid ? const Color(0x2610B981) : const Color(0xFF131A2D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: valid ? const Color(0xFF10B981) : const Color(0xFF222C44)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(valid ? Icons.check_circle_rounded : Icons.circle_outlined, size: 14, color: valid ? const Color(0xFF10B981) : const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, color: valid ? Colors.white : const Color(0xFF94A3B8), fontWeight: valid ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_hasMinLength || !_hasDigit || !_hasSpecial) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      await context.read<AuthNotifier>().register(
            _usernameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text.trim(),
          );
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordValid = _hasMinLength && _hasDigit && _hasSpecial;

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
                boxShadow: const [
                  BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 15)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                const NexusBrandLogo(fontSize: 22, subtitle: 'КИБЕРСПОРТИВНАЯ АРЕНА'),
                                const SizedBox(height: 36),
                                const Text(
                                  'СТАНЬ ЧАСТЬЮ\nКОМЬЮНИТИ NEXUS',
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
                                  'Создайте аккаунт и получите моментальный доступ ко всем возможностям арены:',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                                ),
                                const SizedBox(height: 28),
                                _buildBenefitRow(Icons.card_membership_rounded, 'Клубная карта и кэшбэк до 25% на сессии'),
                                const SizedBox(height: 16),
                                _buildBenefitRow(Icons.sports_esports_rounded, '400+ игр на NVMe SSD без очередей и скачиваний'),
                                const SizedBox(height: 16),
                                _buildBenefitRow(Icons.desktop_windows_rounded, 'Бронирование сетапов на RTX 4080 и RTX 4090'),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12182B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF1E2842)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: Color(0xFFFF5500), size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Официальная площадка для турниров и тренировок команд',
                                      style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                'РЕГИСТРАЦИЯ',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Заполните поля для создания аккаунта игрока',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                              const SizedBox(height: 24),

                              TextFormField(
                                controller: _usernameCtrl,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Никнейм игрока',
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFFFF5500), size: 20),
                                ),
                                validator: (v) => v == null || v.trim().length < 3 ? 'Минимум 3 символа' : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _emailCtrl,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Электронная почта',
                                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFFF5500), size: 20),
                                ),
                                validator: (v) => v != null && v.contains('@') ? null : 'Некорректный email',
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF5500), size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 18,
                                      color: const Color(0xFF64748B),
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                onChanged: _checkPassword,
                              ),
                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildCheckBadge('8+ символов', _hasMinLength),
                                  _buildCheckBadge('Цифра', _hasDigit),
                                  _buildCheckBadge('Спецсимвол', _hasSpecial),
                                ],
                              ),
                              const SizedBox(height: 24),

                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5500),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: (_isLoading || !isPasswordValid) ? null : _submit,
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('ЗАРЕГИСТРИРОВАТЬСЯ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                              ),
                              const SizedBox(height: 16),

                              Center(
                                child: TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text('Уже есть аккаунт? Войти', style: TextStyle(color: Color(0xFFFF5500), fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
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

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2842),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF5500), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }
}