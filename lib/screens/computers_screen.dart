import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/computer.dart';
import '../models/computer_query.dart';
import '../models/club_zone.dart';
import '../models/role.dart';
import '../repositories/zone_repository.dart';
import '../state/auth_notifier.dart';
import '../state/computer_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/cyber_loader.dart';
import '../widgets/nexus_brand_logo.dart';

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
    _searchController =
        TextEditingController(text: widget.queryParams['search'] ?? '');
    _loadZones();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromUrl();
    });
  }

  Future<void> _loadZones() async {
    try {
      final zones = await context.read<ZoneRepository>().findAllActive();
      if (mounted) setState(() => _zones = zones);
    } catch (_) {}
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

    final uri = Uri(
        path: '/computers', queryParameters: params.isEmpty ? null : params);
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
    final auth = context.watch<AuthNotifier>();
    final q = notifier.query;

    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1222),
        title: const NexusBrandLogo(fontSize: 18, subtitle: 'КАТАЛОГ СЕТАПОВ'),
        actions: [
          if (auth.user != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: auth.user!.role == Role.admin
                      ? const Color(0x2EFBBF24)
                      : const Color(0x2E6366F1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: auth.user!.role == Role.admin
                        ? const Color(0x66FBBF24)
                        : const Color(0x66818CF8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.user!.role == Role.admin
                          ? Icons.shield_rounded
                          : Icons.person_rounded,
                      size: 14,
                      color: auth.user!.role == Role.admin
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF818CF8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${auth.user!.username} (${auth.user!.role.label})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: auth.user!.role == Role.admin
                            ? const Color(0xFFFBBF24)
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF080C16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E283D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => context.go('/dashboard'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Главная',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5500),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Компьютеры',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                InkWell(
                  onTap: () => context.go('/zones'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Зоны зала',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/members'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Клиенты',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                if (auth.has(Role.admin))
                  InkWell(
                    onTap: () => context.go('/admin/users'),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Text('Персонал',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF5500),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                IconButton(
                  tooltip: 'Выход',
                  icon: const Icon(Icons.logout_rounded,
                      size: 18, color: Color(0xFFEF4444)),
                  onPressed: () => auth.logout(),
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
            Card(
              color: const Color(0xFF0F1527),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF1E2842)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                                  'Поиск по названию ПК, видеокарте или процессору...',
                              prefixIcon: const Icon(Icons.search_rounded,
                                  size: 20, color: Color(0xFFFF5500)),
                              filled: true,
                              fillColor: const Color(0xFF080C16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFF1E2842)),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        notifier
                                            .applyQuery(q.copyWith(search: ''));
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
                        if (auth.has(Role.operator)) ...[
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5500),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.go('/computers/new'),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Добавить ПК',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
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
                            color: const Color(0xFF080C16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E2842)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: q.zoneId,
                              dropdownColor: const Color(0xFF0F1527),
                              hint: const Text('Все зоны зала',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF94A3B8))),
                              items: [
                                const DropdownMenuItem(
                                    value: null,
                                    child: Text('Все зоны зала',
                                        style: TextStyle(fontSize: 13))),
                                ..._zones.map((z) => DropdownMenuItem(
                                    value: z.id,
                                    child: Text(z.name,
                                        style: const TextStyle(fontSize: 13)))),
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
                            color: const Color(0xFF080C16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1E2842)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<bool?>(
                              value: q.isVip,
                              dropdownColor: const Color(0xFF0F1527),
                              hint: const Text('Все тарифы',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF94A3B8))),
                              items: const [
                                DropdownMenuItem(
                                    value: null,
                                    child: Text('Все тарифы',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: true,
                                    child: Text('Только VIP',
                                        style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(
                                    value: false,
                                    child: Text('Обычные места',
                                        style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) {
                                notifier.applyQuery(q.copyWith(isVip: val));
                                _pushQueryToUrl(notifier.query);
                              },
                            ),
                          ),
                        ),
                        FilterChip(
                          backgroundColor: const Color(0xFF080C16),
                          side: BorderSide(
                              color: q.includeDeleted
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF1E2842)),
                          label: Text(
                            'Показать архивные',
                            style: TextStyle(
                                fontSize: 13,
                                color: q.includeDeleted
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFF94A3B8)),
                          ),
                          selected: q.includeDeleted,
                          onSelected: (val) {
                            notifier
                                .applyQuery(q.copyWith(includeDeleted: val));
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
            if (notifier.hasSelection && auth.has(Role.operator))
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1319),
                  border: Border.all(color: const Color(0xFF7F1D1D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text('Выбрано ПК: ${notifier.selected.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444)),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Удалить выбранные',
                          style: TextStyle(fontSize: 13)),
                      onPressed: () async {
                        final count = await notifier.deleteSelected();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Удалено записей: $count')));
                        }
                      },
                    ),
                  ],
                ),
              ),
            switch (notifier.status) {
              LoadStatus.loading =>
                const CyberLoader(message: 'Загрузка каталога сетапов...'),
              LoadStatus.error => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          notifier.error ?? 'Ошибка загрузки данных с сервера',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFF87171), fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => notifier.load(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Повторить попытку'),
                        ),
                      ],
                    ),
                  ),
                ),
              _ when notifier.result.items.isEmpty => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: Color(0xFF64748B)),
                        SizedBox(height: 12),
                        Text('Компьютеры не найдены',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                            'Попробуйте изменить поисковый запрос или сбросить фильтры.',
                            style: TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 13)),
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
                      onToggleSelect: auth.has(Role.operator)
                          ? (id) => notifier.toggleSelection(id)
                          : null,
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
                      columns: [
                        TableColumnSpec<Computer>(
                          label: 'Компьютер',
                          sortField: 'name',
                          build: (c) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              if (c.isVip) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x26FBBF24),
                                    border: Border.all(
                                        color: const Color(0x66FBBF24)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('VIP',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFBBF24))),
                                ),
                              ],
                              if (c.isDeleted) ...[
                                const SizedBox(width: 8),
                                const Text('(В архиве)',
                                    style: TextStyle(
                                        color: Color(0xFFF87171),
                                        fontSize: 11)),
                              ],
                            ],
                          ),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'IP-адрес',
                          build: (c) => Text(c.ipAddress,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF94A3B8))),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Видеокарта',
                          sortField: 'gpu',
                          build: (c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131A2F),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFF1F2B4B)),
                            ),
                            child: Text(c.gpu,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFE2E8F0))),
                          ),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Процессор',
                          build: (c) => Text(c.cpu,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'ОЗУ',
                          sortField: 'ram',
                          numeric: true,
                          build: (c) => Text('${c.ramGb} ГБ',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        TableColumnSpec<Computer>(
                          label: 'Тариф',
                          sortField: 'rate',
                          numeric: true,
                          build: (c) => Text(
                            '${c.hourlyRate.toInt()} ₽/ч',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFFF5500)),
                          ),
                        ),
                      ],
                      actions: auth.has(Role.operator)
                          ? (c) => [
                                IconButton(
                                  tooltip: 'Редактировать',
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 19, color: Color(0xFF38BDF8)),
                                  onPressed: () =>
                                      context.go('/computers/${c.id}/edit'),
                                ),
                                if (!c.isDeleted)
                                  IconButton(
                                    tooltip: 'В архив',
                                    icon: const Icon(Icons.delete_outline,
                                        size: 19, color: Color(0xFF94A3B8)),
                                    onPressed: () => notifier.softDelete(c.id),
                                  )
                                else ...[
                                  IconButton(
                                    tooltip: 'Восстановить',
                                    icon: const Icon(Icons.restore,
                                        size: 19, color: Color(0xFF10B981)),
                                    onPressed: () => notifier.restore(c.id),
                                  ),
                                  if (auth.has(Role.admin))
                                    IconButton(
                                      tooltip: 'Удалить навсегда (Admin)',
                                      icon: const Icon(Icons.delete_forever,
                                          size: 19, color: Color(0xFFEF4444)),
                                      onPressed: () =>
                                          notifier.hardDelete(c.id),
                                    ),
                                ],
                              ]
                          : null,
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
