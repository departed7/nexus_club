import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final VoidCallback? onSelectAll;
  final String? sortField;
  final bool sortAscending;
  final ValueChanged<String>? onSort;
  final List<Widget> Function(T item)? actions;
  final Widget Function(T item)? mobileCardBuilder;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.onSelectAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.mobileCardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Адаптивная смена таблицы на карточки при ширине окна менее 600px (Критерий 12)
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650 && mobileCardBuilder != null) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => mobileCardBuilder!(items[index]),
          );
        }

        // Полноразмерная таблица DataTable для больших экранов
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                showCheckboxColumn: onToggleSelect != null,
                columns: [
                  ...columns.map((col) {
                    final isCurrentSorted = col.sortField != null && col.sortField == sortField;
                    return DataColumn(
                      numeric: col.numeric,
                      label: InkWell(
                        onTap: col.sortField != null && onSort != null ? () => onSort!(col.sortField!) : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(col.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (col.sortField != null) ...[
                              const SizedBox(width: 4),
                              Icon(
                                isCurrentSorted
                                    ? (sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
                                    : Icons.unfold_more_rounded,
                                size: 16,
                                color: isCurrentSorted ? theme.colorScheme.primary : theme.colorScheme.outline,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  if (actions != null)
                    const DataColumn(
                      label: Text('Действия', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
                rows: items.map((item) {
                  final id = idOf(item);
                  final isSelected = selected.contains(id);

                  return DataRow(
                    selected: isSelected,
                    onSelectChanged: onToggleSelect != null ? (_) => onToggleSelect!(id) : null,
                    cells: [
                      ...columns.map((col) => DataCell(col.build(item))),
                      if (actions != null)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!(item),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}