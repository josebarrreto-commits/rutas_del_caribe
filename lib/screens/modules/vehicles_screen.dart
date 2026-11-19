import 'package:flutter/material.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

const _editFields = [
  FormFieldDef('identificacionConductor', 'Identificación del conductor', required: false),
  FormFieldDef('tarifaId', 'ID de la tarifa (activa)', type: FieldType.number, required: false),
  FormFieldDef('vigenciaSoat', 'Vigencia SOAT', type: FieldType.date, required: false),
  FormFieldDef('vigenciaTrm', 'Vigencia TRM', type: FieldType.date, required: false),
  FormFieldDef('fechaIngreso', 'Fecha de ingreso', type: FieldType.date, required: false),
  FormFieldDef('activo', 'Activo', type: FieldType.bool),
];

String? _driverId(Map<String, dynamic> m) {
  final direct = m['identificacionConductor'];
  if (direct != null && direct.toString().isNotEmpty) {
    return direct.toString();
  }
  final c = m['conductor'];
  if (c is Map) {
    final v = c['Identificacion'] ?? c['identificacion'];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  return null;
}

Map<String, dynamic> _vehicleValues(Map<String, dynamic> m) => {
  ...m,
  'tarifaId': m['tarifa'] is Map ? (m['tarifa'] as Map)['id'] : m['tarifaId'],
  'identificacionConductor': _driverId(m),
};

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Vehículos',
    description: 'Consulta y gestiona los vehículos de la cooperativa.',
    icon: Icons.directions_bus_outlined,
    path: '/vehiculos',
    titleOf: (m) => field(m, 'placa'),
    subtitleOf: (m) =>
        '${field(m, 'tipo')} · ${field(m, 'marca')} ${field(m, 'modelo')} · ${m['activo'] == false ? 'Inactivo' : 'Activo'}\n'
        'Conductor: ${_driverId(m) ?? 'sin conductor'}',
    idOf: (m) => field(m, 'placa'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nuevo vehículo',
      path: '/vehiculos',
      fields: [
        FormFieldDef('placa', 'Placa'),
        FormFieldDef('tipo', 'Tipo (ej. BUSETA)'),
        FormFieldDef('marca', 'Marca'),
        FormFieldDef('modelo', 'Modelo (año)'),
        FormFieldDef('capacidadPasajeros', 'Capacidad de pasajeros', type: FieldType.number),
        FormFieldDef('tarjetaPropiedad', 'Tarjeta de propiedad'),
        FormFieldDef('tarifaId', 'ID de la tarifa (debe existir y estar activa)', type: FieldType.number),
        FormFieldDef('vigenciaSoat', 'Vigencia SOAT', type: FieldType.date),
        FormFieldDef('vigenciaTrm', 'Vigencia TRM', type: FieldType.date),
        FormFieldDef('fechaIngreso', 'Fecha de ingreso', type: FieldType.date),
        FormFieldDef('activo', 'Activo', type: FieldType.bool),
      ],
    ),
    editFields: _editFields,
    editValues: _vehicleValues,
    extraActions: activeToggleActions(
      path: '/vehiculos',
      noun: 'vehículo',
      idOf: (m) => field(m, 'placa'),
      editFields: _editFields,
      editValues: _vehicleValues,
    ),
  );
}