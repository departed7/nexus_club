import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InactivityWatcher extends StatefulWidget {
  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  const InactivityWatcher({
    super.key,
    this.timeout = const Duration(minutes: 3), // 3 минуты по ТЗ
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _timer;
  Timer? _warningTimer;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _restart() {
    _timer?.cancel();
    _warningTimer?.cancel();
    if (_dialogShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
    }

    // Предупреждение за 30 секунд до выхода
    final warningDuration = widget.timeout - const Duration(seconds: 30);
    if (warningDuration > Duration.zero) {
      _warningTimer = Timer(warningDuration, _showWarningDialog);
    }
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  void _showWarningDialog() {
    if (!mounted || _dialogShown) return;
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        title: const Row(
          children: [
            Icon(Icons.timer_outlined, color: Color(0xFFFBBF24)),
            SizedBox(width: 8),
            Text('Завершение сессии'),
          ],
        ),
        content: const Text('Вы не проявляли активности. Сессия завершится через 30 секунд в целях безопасности.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _dialogShown = false;
              _restart();
            },
            child: const Text('Я здесь (Продлить)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}