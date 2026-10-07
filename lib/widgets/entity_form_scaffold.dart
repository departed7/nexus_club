import 'package:flutter/material.dart';

class EntityFormScaffold extends StatelessWidget {
  final String title;
  final bool isDirty;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final Widget child;

  const EntityFormScaffold({
    super.key,
    required this.title,
    required this.isDirty,
    required this.isSubmitting,
    required this.onSubmit,
    required this.child,
  });

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        title: const Text('Несохранённые изменения'),
        content: const Text('В форме есть несохранённые данные. Вы действительно хотите покинуть экран?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Сбросить и выйти'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          actions: [
            if (isDirty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Text('• Есть изменения', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 12)),
                ),
              ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      child,
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              if (isDirty) {
                                final shouldPop = await _showDiscardDialog(context);
                                if (shouldPop && context.mounted) Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Отмена'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: isSubmitting ? null : onSubmit,
                            icon: isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.check_rounded, size: 18),
                            label: Text(isSubmitting ? 'Сохранение...' : 'Сохранить'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}