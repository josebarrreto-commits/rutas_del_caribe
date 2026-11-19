import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

List<Map<String, dynamic>> _list(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : [];

class _BulkPlanillasScreen extends StatefulWidget {
  const _BulkPlanillasScreen();

  @override
  State<_BulkPlanillasScreen> createState() => _BulkPlanillasScreenState();
}

class _BulkPlanillasScreenState extends State<_BulkPlanillasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fecha = TextEditingController();
  final _tipo = TextEditingController(text: 'VIAJE');
  final _tarifa = TextEditingController();
  final _placas = TextEditingController();

  bool _saving = false;
  bool _created = false;
  Map<String, dynamic>? _report;

  @override
  void dispose() {
    _fecha.dispose();
    _tipo.dispose();
    _tarifa.dispose();
    _placas.dispose();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fecha.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _fecha.text = '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final placas = _placas.text
        .split(RegExp(r'[\s,;]+'))
        .map((p) => p.trim().toUpperCase())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    if (placas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe al menos una placa.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _report = null;
    });

    try {
      final res = await ApiService().post('/planillas/masivas', {
        'fecha': _fecha.text.trim(),
        'placasVehiculos': placas,
        'tipo': _tipo.text.trim(),
        'tarifaId': num.parse(_tarifa.text.trim()),
      });

      final data = (res is Map && res['data'] is Map)
          ? Map<String, dynamic>.from(res['data'] as Map)
          : (res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{});
      debugPrint('[Planillas masivas] respuesta: $res');
      final registered = _list(data['correctas']);
      if (registered.isNotEmpty) _created = true;

      if (!mounted) return;
      setState(() {
        _report = data;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _reportView() {
    final r = _report!;
    final ok = _list(r['correctas']);
    final bad = _list(r['rechazadas']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Solicitadas: ${field(r, 'totalSolicitadas')}   '
          'Registradas: ${field(r, 'totalRegistradas')}   '
          'Rechazadas: ${field(r, 'totalRechazadas')}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        for (final p in ok)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle,
                    size: 18, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Planilla ${field(p, 'numero')} · ${field(p, 'placaVehiculo')}',
                  ),
                ),
              ],
            ),
          ),
        for (final b in bad)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cancel, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    '${field(b, 'placaVehiculo')}: ${field(b, 'motivo')} '
                    '(${field(b, 'codigo')})',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, _created),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) Navigator.pop(context, _created);
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Nuevas planillas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fecha,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tarifa,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID de la tarifa (activa)',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Obligatorio';
                  return num.tryParse(t) == null ? 'Debe ser un número' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placas,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placas (separadas por coma o por línea)',
                  hintText: 'TRB101, TRB102, TRB103',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear planillas'),
                ),
              ),
              if (_report != null) _reportView(),
            ],
          ),
        ),
      ),
    ),
  );
}

class PlanillasScreen extends StatelessWidget {
  const PlanillasScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Planillas',
    description: 'Consulta y gestiona las planillas de viaje.',
    icon: Icons.description_outlined,
    path: '/planillas',
    titleOf: (m) => 'Planilla ${field(m, 'numero')} · ${field(m, 'placaVehiculo')}',
    subtitleOf: (m) =>
        '${field(m, 'fecha')} · ${field(m, 'estado')} · Pago ${field(m, 'estadoPago')}',
    idOf: (m) => field(m, 'numero'),
    formBuilder: (_) => const _BulkPlanillasScreen(),
    deleteAction: const DeleteAction(
      label: 'Anular',
      message: '¿Anular esta planilla? Se conservan el historial y los pagos.',
    ),
  );
}