import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/club_zone.dart';
import '../models/zone_query.dart';
import '../repositories/computer_repository.dart';
import '../state/zone_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/nexus_brand_logo.dart';

class ZonesScreen extends StatefulWidget {
  final Map<String, String> queryParams;
  const ZonesScreen({super.key, required this.queryParams});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.queryParams['search'] ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final q = ZoneQuery(
        search: widget.queryParams['search'] ?? '',
        sortField: widget.queryParams['sort'] ?? 'name',
        sortAscending: widget.queryParams['desc'] != 'true',
        page: int.tryParse(widget.queryParams['page'] ?? '') ?? 1,
        size: int.tryParse(widget.queryParams['size'] ?? '') ?? 10,
        includeDeleted: widget.queryParams['deleted'] == 'true',
      );
      context.read<ZoneListNotifier>().applyQuery(q);
    });
  }

  void _pushQueryToUrl(ZoneQuery q) {
    final params = <String, String>{};
    if (q.search.isNotEmpty) params['search'] = q.search;
    if (q.sortField != 'name') params['sort'] = q.sortField;
    if (!q.sortAscending) params['desc'] = 'true';
    if (q.page > 1) params['page'] = q.page.toString();
    if (q.size != 10) params['size'] = q.size.toString();
    if (q.includeDeleted) params['deleted'] = 'true';

    final uri = Uri(path: '/zones', queryParameters: params.isEmpty ? null : params);
    context.go(uri.toString());
  }

  Future<void> _handleDeleteZone(ClubZone zone) async {
    final compRepo = context.read<ComputerRepository>();
    final linkedComputersCount = await compRepo.countByZoneId(zone.id);

    if (linkedComputersCount > 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F1527),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5500)),
              SizedBox(width: 8),
              Text('Невозможно удалить зону'),
            ],
          ),
          content: Text('К зоне "${zone.name}" привязано $linkedComputersCount ПК.\nПеренесите компьютеры перед удалением.'),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5500)),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) context.read<ZoneListNotifier>().softDelete(zone.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ZoneListNotifier>();
    final q = notifier.query;

    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1222),
        title: const NexusBrandLogo(fontSize: 18, subtitle: 'ЗОНЫ И ТАРИФЫ'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        actions: [
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
                InkWell(onTap: () => context.go('/dashboard'), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: Text('Главная', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)))),
                InkWell(onTap: () => context.go('/computers'), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: Text('Компьютеры', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF5500), borderRadius: BorderRadius.circular(8)), child: const Text('Зоны зала', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                InkWell(onTap: () => context.go('/members'), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: Text('Клиенты', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)))),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF0F1527),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF1E2842)), borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Поиск по названию или описанию зоны...',
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFFF5500)),
                    filled: true,
                    fillColor: Color(0xFF080C16),
                  ),
                  onChanged: (text) {
                    notifier.applyQuery(q.copyWith(search: text));
                    _pushQueryToUrl(notifier.query);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            EntityTable<ClubZone>(
              items: notifier.result.items,
              idOf: (z) => z.id,
              sortField: q.sortField,
              sortAscending: q.sortAscending,
              onSort: (field) {
                notifier.applyQuery(q.copyWith(sortField: field, sortAscending: q.sortField == field ? !q.sortAscending : true));
                _pushQueryToUrl(notifier.query);
              },
              columns: [
                TableColumnSpec<ClubZone>(label: 'Зона клуба', sortField: 'name', build: (z) => Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                TableColumnSpec<ClubZone>(label: 'Описание и оснащение', build: (z) => Text(z.description, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))),
                TableColumnSpec<ClubZone>(label: 'Тариф', sortField: 'price', numeric: true, build: (z) => Text('${z.hourlyPrice.toInt()} ₽/ч', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5500), fontSize: 14))),
              ],
              actions: (z) => [
                IconButton(tooltip: 'Удалить зону', icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF94A3B8)), onPressed: () => _handleDeleteZone(z)),
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
      ),
    );
  }
}