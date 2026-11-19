import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/module_screen.dart';

String _s(Map<String, dynamic> m, String key) {
  final v = m[key];
  return v == null ? '' : v.toString();
}

String _key(Map<String, dynamic> m) {
  String n(String k) =>
      (num.tryParse(_s(m, k)) ?? 0).toDouble().toString();
  return '${n('aportesGastosVarios')}|${n('fondoReposicion')}|${n('aporteSocialSocio')}';
}

class FaresScreen extends StatefulWidget {
  const FaresScreen({super.key});

  @override
  State<FaresScreen> createState() => _FaresScreenState();
}

class _FaresScreenState extends State<FaresScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _items = [];
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService().get('/tarifas?page=1&pageSize=50');
      List<dynamic> raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map) {
        final inner = data['data'];
        if (inner is List) {
          raw = inner;
        } else if (inner is Map && inner['items'] is List) {
          raw = inner['items'] as List;
        }
      }
      final all = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (all.isNotEmpty) debugPrint('[Tarifas] ejemplo: ${all.first}');

      final activeKeys = all
          .where((m) => m['activo'] != false)
          .map(_key)
          .toSet();
      final visible = all
          .where((m) => m['activo'] != false || !activeKeys.contains(_key(m)))
          .toList();

      if (!mounted) return;
      setState(() {
        _all = all;
        _items = visible;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deactivate(Map<String, dynamic> item) async {
    final id = _s(item, 'id');
    if (id.isEmpty || _busy.contains(id)) return;

    final ok = await _confirm(
      'Inactivar tarifa',
      '¿Inactivar la tarifa #$id? Después podrás activarla de nuevo.',
      'Inactivar',
    );
    if (!ok) return;

    setState(() => _busy.add(id));
    try {
      await ApiService().delete('/tarifas/${Uri.encodeComponent(id)}');
      _msg('Tarifa #$id inactivada.');
      await _load();
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _activate(Map<String, dynamic> item) async {
    final id = _s(item, 'id');
    if (id.isEmpty || _busy.contains(id)) return;

    final existing = _all.where(
      (m) => m['activo'] != false && _key(m) == _key(item),
    );
    if (existing.isNotEmpty) {
      _msg(
        'Ya existe la tarifa activa #${_s(existing.first, 'id')} '
        'con estos mismos valores.',
      );
      return;
    }

    final body = <String, dynamic>{
      'aportesGastosVarios': item['aportesGastosVarios'],
      'fondoReposicion': item['fondoReposicion'],
      'aporteSocialSocio': item['aporteSocialSocio'],
      'activo': true,
    };

    if (body.values.any((v) => v == null)) {
      _msg(
        'No se encontraron los valores de la tarifa #$id. '
        'Créala manualmente con Nuevo registro.',
      );
      return;
    }

    final ok = await _confirm(
      'Activar tarifa',
      'La API no permite reactivar una tarifa. Se creará una tarifa nueva, '
          'activa, con los mismos valores de la #$id. Los vehículos que usaban '
          'la #$id deben cambiarse a la nueva con Editar.',
      'Activar',
    );
    if (!ok) return;

    setState(() => _busy.add(id));
    try {
      await ApiService().post('/tarifas', body);
      _msg('Tarifa nueva creada y activa.');
      await _load();
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _newRecord() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RecordFormScreen(
          title: 'Nueva tarifa',
          path: '/tarifas',
          fields: [
            FormFieldDef('aportesGastosVarios', 'Aportes gastos varios',
                type: FieldType.number),
            FormFieldDef('fondoReposicion', 'Fondo de reposición',
                type: FieldType.number),
            FormFieldDef('aporteSocialSocio', 'Aporte social socio',
                type: FieldType.number),
            FormFieldDef('activo', 'Activa', type: FieldType.bool),
          ],
        ),
      ),
    );
    if (created == true && mounted) {
      _msg('Tarifa creada correctamente.');
      await _load();
    }
  }

  Widget _card(Map<String, dynamic> item) {
    final id = _s(item, 'id');
    final inactive = item['activo'] == false;
    final busy = _busy.contains(id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tarifa #$id',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: inactive
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    inactive ? 'Inactiva' : 'Activa',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: inactive ? Colors.red : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Total ${_s(item, 'total')}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : inactive
                      ? FilledButton.icon(
                          onPressed: () => _activate(item),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 18),
                          label: const Text('Activar'),
                        )
                      : TextButton.icon(
                          onPressed: () => _deactivate(item),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Inactivar'),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Sin registros'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _card(_items[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tarifas')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.turquoise.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.payments_outlined,
                color: AppColors.navy, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tarifas',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        const Text(
          'Consulta y gestiona las tarifas (solo gerente).',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        Expanded(child: _body()),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _newRecord,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo registro'),
          ),
        ),
      ]),
    ),
  );
}