import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/computer.dart';
import '../models/club_zone.dart';
import '../models/game.dart';
import '../models/tariff.dart';
import '../repositories/computer_repository.dart';
import '../repositories/zone_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/tariff_repository.dart';
import '../state/computer_list_notifier.dart';
import '../utils/validators.dart';
import '../widgets/entity_form_scaffold.dart';
import '../core/api_exceptions.dart';

class ComputerFormScreen extends StatefulWidget {
  final int? id;
  const ComputerFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<ComputerFormScreen> createState() => _ComputerFormScreenState();
}

class _ComputerFormScreenState extends State<ComputerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _gpuController = TextEditingController();
  final _cpuController = TextEditingController();
  final _ramController = TextEditingController();
  final _rateController = TextEditingController();
  final _ipController = TextEditingController();

  int? _zoneId;
  List<int> _gameIds = [];
  bool _isVip = false;

  bool _isDirty = false;
  bool _isSubmitting = false;
  bool _isLoading = true;

  List<ClubZone> _zones = [];
  List<Game> _games = [];
  List<Tariff> _availableTariffs = [];

  String? _ipUniqueError;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  Future<void> _loadDependencies() async {
    final zoneRepo = context.read<ZoneRepository>();
    final gameRepo = context.read<GameRepository>();
    final compRepo = context.read<ComputerRepository>();

    final zones = await zoneRepo.findAllActive();
    final games = await gameRepo.findAllActive();

    if (!mounted) return;
    setState(() {
      _zones = zones;
      _games = games;
    });

    if (widget.isEditing) {
      final comp = await compRepo.findById(widget.id!);
      if (!mounted) return;
      if (comp != null) {
        _nameController.text = comp.name;
        _gpuController.text = comp.gpu;
        _cpuController.text = comp.cpu;
        _ramController.text = comp.ramGb.toString();
        _rateController.text = comp.hourlyRate.toInt().toString();
        _ipController.text = comp.ipAddress;
        _zoneId = comp.zoneId;
        _gameIds = List.from(comp.gameIds);
        _isVip = comp.isVip;
        await _loadTariffsForZone(_zoneId!);
      }
    } else {
      if (_zones.isNotEmpty) {
        _zoneId = _zones.first.id;
        _rateController.text = _zones.first.hourlyPrice.toInt().toString();
        await _loadTariffsForZone(_zoneId!);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTariffsForZone(int zoneId) async {
    final tariffRepo = context.read<TariffRepository>();
    final tariffs = await tariffRepo.findByZoneId(zoneId);
    if (mounted) setState(() => _availableTariffs = tariffs);
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _submit() async {
    _ipUniqueError = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final repo = context.read<ComputerRepository>();
    final notifier = context.read<ComputerListNotifier>();

    final computer = Computer(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      gpu: _gpuController.text.trim(),
      cpu: _cpuController.text.trim(),
      ramGb: int.parse(_ramController.text.trim()),
      zoneId: _zoneId!,
      gameIds: _gameIds,
      hourlyRate: double.parse(_rateController.text.trim()),
      isVip: _isVip,
      ipAddress: _ipController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await repo.update(computer);
      } else {
        await repo.create(computer);
      }

      if (!mounted) return;
      await notifier.load();
      if (!mounted) return;
      context.go('/computers');
    } on ValidationException catch (e) {
      // Сервер вернул 422 Unprocessable Entity (Критерий 9)
      setState(() {
        _isSubmitting = false;
        _ipUniqueError = e.errors['ipAddress'] ?? e.message;
      });
      _formKey.currentState!.validate();
    } on ApiException catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gpuController.dispose();
    _cpuController.dispose();
    _ramController.dispose();
    _rateController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return EntityFormScaffold(
      title: widget.isEditing ? 'Редактирование сетапа #${widget.id}' : 'Новый игровой компьютер',
      isDirty: _isDirty,
      isSubmitting: _isSubmitting,
      onSubmit: _submit,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('ИДЕНТИФИКАЦИЯ МЕСТА', Icons.computer_rounded, const Color(0xFF38BDF8)),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Название ПК (NEXUS-XX)'),
                    onChanged: (_) => _markDirty(),
                    validator: (v) => Validators.required(v) ?? Validators.minLength(v, 3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      labelText: 'IP-адрес (Уникальный)',
                      errorText: _ipUniqueError,
                    ),
                    onChanged: (_) {
                      _ipUniqueError = null;
                      _markDirty();
                    },
                    validator: (v) => _ipUniqueError ?? Validators.ipAddress(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('ЗОНА И ТАРИФИКАЦИЯ (СВЯЗЬ N:1)', Icons.meeting_room_rounded, const Color(0xFFFBBF24)),
            DropdownButtonFormField<int>(
              initialValue: _zoneId,
              decoration: const InputDecoration(labelText: 'Игровая зона зала'),
              items: _zones.map((z) => DropdownMenuItem(value: z.id, child: Text('${z.name} (${z.hourlyPrice.toInt()} ₽/ч)'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _zoneId = val;
                    final zone = _zones.firstWhere((z) => z.id == val);
                    _rateController.text = zone.hourlyPrice.toInt().toString();
                    _markDirty();
                  });
                  _loadTariffsForZone(val);
                }
              },
              validator: (v) => v == null ? 'Выберите зону' : null,
            ),
            const SizedBox(height: 12),

            if (_availableTariffs.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF24304A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Пакетные тарифы зоны (Каскадный отбор):', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableTariffs.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E283D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${t.name} • ${t.price.toInt()} ₽', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00E599))),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionHeader('КОНФИГУРАЦИЯ ОБОРУДОВАНИЯ', Icons.memory_rounded, const Color(0xFF00E599)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gpuController,
                    decoration: const InputDecoration(labelText: 'Видеокарта'),
                    onChanged: (_) => _markDirty(),
                    validator: (v) => Validators.required(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cpuController,
                    decoration: const InputDecoration(labelText: 'Процессор'),
                    onChanged: (_) => _markDirty(),
                    validator: (v) => Validators.required(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ramController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ОЗУ (ГБ)'),
                    onChanged: (_) => _markDirty(),
                    validator: (v) => Validators.numberRange(v, 8, 128),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Тариф (₽/час)'),
                    onChanged: (_) => _markDirty(),
                    validator: (v) => Validators.positiveNumber(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('ПРЕДУСТАНОВЛЕННЫЕ ИГРЫ (СВЯЗЬ N:N)', Icons.sports_esports_rounded, const Color(0xFFA855F7)),
            FormField<List<int>>(
              initialValue: _gameIds,
              validator: (v) => (v == null || v.isEmpty) ? 'Выберите хотя бы одну игру' : null,
              builder: (field) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Каталог игр на ПК',
                    errorText: field.errorText,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _games.map((g) {
                      final isSelected = field.value!.contains(g.id);
                      return FilterChip(
                        label: Text(g.title),
                        selected: isSelected,
                        selectedColor: const Color(0xFF00E599).withValues(alpha: 0.25),
                        checkmarkColor: const Color(0xFF00E599),
                        onSelected: (_) {
                          final next = List<int>.from(field.value!);
                          if (isSelected) {
                            next.remove(g.id);
                          } else {
                            next.add(g.id);
                          }
                          field.didChange(next);
                          setState(() => _gameIds = next);
                          _markDirty();
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: const Color(0xFFFBBF24),
              title: const Text('VIP статус компьютера', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Золотой бейдж в каталоге и приоритет на бронирование'),
              value: _isVip,
              onChanged: (val) {
                setState(() => _isVip = val);
                _markDirty();
              },
            ),
          ],
        ),
      ),
    );
  }
}