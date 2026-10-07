import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/club_zone.dart';
import '../models/zone_query.dart';
import '../state/zone_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';

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
              child: const Icon(Icons.meeting_room_outlined, size: 20, color: Color(0xFF38BDF8)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Зоны зала',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
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
                InkWell(
                  onTap: () => context.go('/computers'),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Компьютеры', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Зоны клуба', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Поиск по названию или описанию зоны...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
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
                final isSame = q.sortField == field;
                notifier.applyQuery(q.copyWith(
                  sortField: field,
                  sortAscending: isSame ? !q.sortAscending : true,
                ));
                _pushQueryToUrl(notifier.query);
              },
              mobileCardBuilder: (z) => Card(
                child: ListTile(
                  title: Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(z.description),
                  trailing: Text('${z.hourlyPrice.toInt()} ₽/ч', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                ),
              ),
              columns: [
                TableColumnSpec<ClubZone>(
                  label: 'Зона клуба',
                  sortField: 'name',
                  build: (z) => Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                TableColumnSpec<ClubZone>(
                  label: 'Описание и оснащение',
                  build: (z) => Text(z.description, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                ),
                TableColumnSpec<ClubZone>(
                  label: 'Тариф',
                  sortField: 'price',
                  numeric: true,
                  build: (z) => Text('${z.hourlyPrice.toInt()} ₽/ч',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), fontSize: 14)),
                ),
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