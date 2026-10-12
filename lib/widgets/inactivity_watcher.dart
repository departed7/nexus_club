import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../router.dart';

class InactivityWatcher extends StatefulWidget {
  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  const InactivityWatcher({
    super.key,
    this.timeout = const Duration(seconds: 20), // 20 секунд общего таймаута
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _timer;
  Timer? _warningTimer;
  Timer? _countdownTicker;
  int _secondsLeft = 12;
  bool _isWarningOpen = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restartTimers();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _cancelAll();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (!_isWarningOpen) _restartTimers();
    return false;
  }

  void _cancelAll() {
    _timer?.cancel();
    _warningTimer?.cancel();
    _countdownTicker?.cancel();
  }

  void _restartTimers() {
    _cancelAll();
    // Предупреждение выскочит уже через 8 секунд бездействия
    _warningTimer = Timer(const Duration(seconds: 8), _showCountdownDialog);
    _timer = Timer(widget.timeout, _handleTimeout);
  }

  void _handleTimeout() {
    if (_isWarningOpen) {
      final nav = rootNavigatorKey.currentState;
      if (nav != null && nav.canPop()) nav.pop();
      _isWarningOpen = false;
    }
    widget.onTimeout();
  }

  void _showCountdownDialog() {
    if (_isWarningOpen) return;
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;

    _isWarningOpen = true;
    _secondsLeft = 12;

    showDialog(
      context: navContext,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          _countdownTicker?.cancel();
          _countdownTicker = Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) {
              t.cancel();
              return;
            }
            if (_secondsLeft > 1) {
              setDialogState(() => _secondsLeft--);
            } else {
              t.cancel();
            }
          });

          return AlertDialog(
            backgroundColor: const Color(0xFF0F1527),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFFF5500), width: 1.5),
            ),
            title: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFFFF5500), size: 24),
                SizedBox(width: 10),
                Text('Сессия завершается', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Вы не проявляли активности в системе. До автоматического завершения сессии осталось:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151D33),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E2842)),
                  ),
                  child: Center(
                    child: Text(
                      '$_secondsLeft СЕКУНД',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFFF5500), letterSpacing: 2.0),
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _isWarningOpen = false;
                  widget.onTimeout();
                },
                child: const Text('Выйти сейчас', style: TextStyle(color: Color(0xFFEF4444))),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _isWarningOpen = false;
                  _restartTimers();
                },
                child: const Text('ПРОДЛИТЬ СЕССИЮ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _isWarningOpen ? null : _restartTimers(),
      onPointerMove: (_) => _isWarningOpen ? null : _restartTimers(),
      child: widget.child,
    );
  }
}