import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int page;
  final int size;
  final int total;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<int> onPageChange;
  final ValueChanged<int> onSizeChange;

  const PaginationBar({
    super.key,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPageChange,
    required this.onSizeChange,
  });

  @override
  Widget build(BuildContext context) {
    final startItem = total == 0 ? 0 : (page - 1) * size + 1;
    final endItem = (page * size) > total ? total : (page * size);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          final leftBlock = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Строк:', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: size,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF8B949E)),
                    style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 13, fontWeight: FontWeight.bold),
                    dropdownColor: const Color(0xFF161B22),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10')),
                      DropdownMenuItem(value: 25, child: Text('25')),
                      DropdownMenuItem(value: 50, child: Text('50')),
                    ],
                    onChanged: (val) {
                      if (val != null) onSizeChange(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Показано $startItem–$endItem из $total',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
              ),
            ],
          );

          final rightBlock = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Text(
                  'Стр. $page из $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF00F0FF)),
                ),
              ),
              const SizedBox(width: 12),
              _PageButton(
                tooltip: 'В начало',
                icon: Icons.first_page_rounded,
                onPressed: hasPrevious ? () => onPageChange(1) : null,
              ),
              const SizedBox(width: 6),
              _PageButton(
                tooltip: 'Назад',
                icon: Icons.chevron_left_rounded,
                onPressed: hasPrevious ? () => onPageChange(page - 1) : null,
              ),
              const SizedBox(width: 6),
              _PageButton(
                tooltip: 'Вперед',
                icon: Icons.chevron_right_rounded,
                onPressed: hasNext ? () => onPageChange(page + 1) : null,
              ),
              const SizedBox(width: 6),
              _PageButton(
                tooltip: 'В конец',
                icon: Icons.last_page_rounded,
                onPressed: hasNext ? () => onPageChange(totalPages) : null,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: leftBlock),
                const SizedBox(height: 12),
                Center(child: rightBlock),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leftBlock,
              rightBlock,
            ],
          );
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFF0D1117) : const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? const Color(0xFF30363D) : const Color(0xFF21262D),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled ? const Color(0xFFC9D1D9) : const Color(0xFF484F58),
          ),
        ),
      ),
    );
  }
}