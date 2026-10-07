import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/computer.dart';
import '../models/computer_query.dart';
import '../repositories/zone_repository.dart';
import '../models/club_zone.dart';
import '../state/computer_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';

class ComputersScreen extends StatefulWidget {
  final Map<String, String> queryParams;
  const ComputersScreen({super.key, required this.queryParams});

  @override
  State<ComputersScreen> createState() => _ComputersScreenState();
}

class _ComputersScreenState extends State<ComputersScreen> {
  late final TextEditingController _searchController;
  List<ClubZone> _zones = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.queryParams['search'] ?? '');
    _loadZones();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromUrl();
    });
  }

  Future<void> _loadZones() async {
    final zones = await context.read<ZoneRepository>().findAllActive();
    if (mounted) setState(() => _zones = zones);
  }

  void _syncFromUrl() {
    final q = widget.queryParams;
    final initialQuery = ComputerQuery(
      search: q['search'] ?? '',
      zoneId: int.tryParse(q['zoneId'] ?? ''),
      minRate: double.tryParse(q['minRate'] ?? ''),
      maxRate: double.tryParse(q['maxRate'] ?? ''),
      isVip: q['isVip'] == null ? null : q['isVip'] == 'true',
      sortField: q['sort'] ?? 'name',
      sortAscending: q['desc'] != 'true',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      size: int.tryParse(q['size'] ?? '') ?? 10,
      includeDeleted: q['deleted'] == 'true',
    );
    context.read<ComputerListNotifier>().applyQuery(initialQuery);
  }

  void _pushQueryToUrl(ComputerQuery q) {
    final params = <String, String>{};
    if (q.search.isNotEmpty) params['search'] = q.search;
    if (q.zoneId != null) params['zoneId'] = q.zoneId.toString();
    if (q.minRate != null) params['minRate'] = q.minRate.toString();
    if (q.maxRate != null) params['maxRate'] = q.maxRate.toString();
    if (q.isVip != null) params['isVip'] = q.isVip.toString();
    if (q.sortField != 'name') params['sort'] = q.sortField;
    if (!q.sortAscending) params['desc'] = 'true';
    if (q.page > 1) params['page'] = q.page.toString();
    if (q.size != 10) params['size'] = q.size.toString();
    if (q.includeDeleted) params['deleted'] = 'true';

    final uri = Uri(path: '/computers', queryParameters: params.isEmpty ? null : params);
    context.go(uri.toString());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ComputerListNotifier>();
    final q = notifier.query;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2433),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2D354B)),
              ),
              child: const Icon(Icons.sports_esports_rounded, size: 20, color: Color(0xFF38BDF8)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Nexus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2433),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Admin', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ),
          ],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Компьютеры', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                InkWell(
                  onTap: () => context.go('/zones'),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Зоны клуба', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/members'),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Клиенты', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Панель фильтров и кнопка создания
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Поиск по названию ПК, видеокарте или процессору...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        notifier.applyQuery(q.copyWith(search: ''));
                                        _pushQueryToUrl(notifier.query);
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (text) {
                              notifier.setSearchDebounced(text, () {
                                _pushQueryToUrl(notifier.query);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => context.go('/computers/new'),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Добавить ПК'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10121A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF282E40)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: q.zoneId,
                              dropdownColor: const Color(0xFF161922),
                              hint: const Text('Все зоны зала', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Все зоны зала', style: TextStyle(fontSize: 13))),
                                ..._zones.map((z) => DropdownMenuItem(value: z.id, child: Text(z.name, style: const TextStyle(fontSize: 13)))),
                              ],
                              onChanged: (val) {
                                notifier.applyQuery(q.copyWith(zoneId: val));
                                _pushQueryToUrl(notifier.query);
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10121A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF282E40)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<bool?>(
                              value: q.isVip,
                              dropdownColor: const Color(0xFF161922),
                              hint: const Text('Все тарифы', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Все тарифы', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: true, child: Text('Только VIP', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: false, child: Text('Обычные места', style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) {
                                notifier.applyQuery(q.copyWith(isVip: val));
                                _pushQueryToUrl(notifier.query);
                              },
                            ),
                          ),
                        ),
                        FilterChip(
                          backgroundColor: const Color(0xFF10121A),
                          side: BorderSide(color: q.includeDeleted ? const Color(0xFFE11D48) : const Color(0xFF282E40)),
                          label: Text(
                            'Показать архивные',
                            style: TextStyle(fontSize: 13, color: q.includeDeleted ? const Color(0xFFFB7185) : const Color(0xFF94A3B8)),
                          ),
                          selected: q.includeDeleted,
                          onSelected: (val) {
                            notifier.applyQuery(q.copyWith(includeDeleted: val));
                            _pushQueryToUrl(notifier.query);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (notifier.hasSelection)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF27151A),
                  border: Border.all(color: const Color(0xFF5C1D29)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('Выбрано записей: ${notifier.selected.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Удалить выбранные', style: TextStyle(fontSize: 13)),
                      onPressed: () async {
                        final count = await notifier.deleteSelected();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Удалено записей: $count')));
                        }
                      },
                    ),
                  ],
                ),
              ),

            switch (notifier.status) {
              LoadStatus.loading => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              LoadStatus.error => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(notifier.error ?? 'Ошибка загрузки данных'),
                  ),
                ),
              _ when notifier.result.items.isEmpty => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF64748B)),
                        SizedBox(height: 12),
                        Text('Компьютеры не найдены', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Попробуйте изменить поисковый запрос или сбросить фильтры.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              _ => Column(
                  children: [
                    EntityTable<Computer>(
                      items: notifier.result.items,
                      idOf: (c) => c.id,
                      selected: notifier.selected,
                      onToggleSelect: (id) => notifier.toggleSelection(id),
                      sortField: q.sortField,
                      sortAscending: q.sortAscending,
                      onSort: (field) {
                        final isSame = q.sortField == field;
                        notifier.applyQuery(q.copyWith(
                          sortField: field,
                          sortAscending: isSame ? !q.sortAscending : true,
                        ));
                        _pushQueryToUrl(notifier.query);
                      },
                      mobileCardBuilder: (c) => Card(
                        child: ListTile(
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${c.gpu} • ${c.cpu}\nТариф: ${c.hourlyRate.toInt()} ₽/ч\nIP: ${c.ipAddress}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => context.go('/computers/${c.id}/edit'),
                              ),
                              IconButton(
                                icon: Icon(c.isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_outline),
                                onPressed: () => c.isDeleted ? notifier.restore(c.id) : notifier.softDelete(c.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                      columns: [
                        TableColumnSpec<Computer>(
                          label: 'Компьютер',
                          sortField: 'name',
                          build: (c) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (c.isVip) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2C2210),
                                    border: Border.fromBorderSide(BorderSide(color: Color(0xFF785412))),
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: const Text('VIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
                                ),
                              ],
                              if (c.isDeleted) ...[
                                const SizedBox(width: 8),
                                const Text('(В архиве)', style: TextStyle(color: Color(0xFFFB7185), fontSize: 11)),
                              ],
                            ],
                          ),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'IP-адрес',
                          build: (c) => Text(c.ipAddress, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF94A3B8))),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Видеокарта',
                          sortField: 'gpu',
                          build: (c) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E2230),
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            child: Text(c.gpu, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE2E8F0))),
                          ),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Процессор',
                          build: (c) => Text(c.cpu, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'ОЗУ',
                          sortField: 'ram',
                          numeric: true,
                          build: (c) => Text('${c.ramGb} ГБ', style: const TextStyle(fontSize: 13)),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Тариф',
                          sortField: 'rate',
                          numeric: true,
                          build: (c) => Text(
                            '${c.hourlyRate.toInt()} ₽/ч',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                      actions: (c) => [
                        IconButton(
                          tooltip: 'Редактировать сетап',
                          icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF38BDF8)),
                          onPressed: () => context.go('/computers/${c.id}/edit'),
                        ),
                        if (!c.isDeleted)
                          IconButton(
                            tooltip: 'Отправить в архив',
                            icon: const Icon(Icons.delete_outline, size: 19, color: Color(0xFF94A3B8)),
                            onPressed: () => notifier.softDelete(c.id),
                          )
                        else ...[
                          IconButton(
                            tooltip: 'Восстановить',
                            icon: const Icon(Icons.restore, size: 19, color: Color(0xFF34D399)),
                            onPressed: () => notifier.restore(c.id),
                          ),
                          IconButton(
                            tooltip: 'Удалить навсегда',
                            icon: const Icon(Icons.delete_forever, size: 19, color: Color(0xFFFB7185)),
                            onPressed: () => notifier.hardDelete(c.id),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    PaginationBar(
                      page: q.page,
                      size: q.size,
                      total: notifier.result.total,
                      totalPages: notifier.result.totalPages,
                      hasPrevious: notifier.result.hasPrevious,
                      hasNext: notifier.result.hasNext,
                      onPageChange: (newPage) {
                        notifier.applyQuery(q.copyWith(page: newPage));
                        _pushQueryToUrl(notifier.query);
                      },
                      onSizeChange: (newSize) {
                        notifier.applyQuery(q.copyWith(size: newSize, page: 1));
                        _pushQueryToUrl(notifier.query);
                      },
                    ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}