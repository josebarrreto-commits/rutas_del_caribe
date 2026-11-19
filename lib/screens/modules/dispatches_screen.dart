import 'package:flutter/material.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

class DispatchesScreen extends StatelessWidget {
  const DispatchesScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Despachos',
    description: 'Consulta y gestiona los despachos de vehículos.',
    icon: Icons.departure_board_outlined,
    path: '/despachos',
    titleOf: (m) => '${field(m, 'ruta')} · ${field(m, 'placaVehiculo')}',
    subtitleOf: (m) =>
        '${field(m, 'fecha')} ${field(m, 'hora')} · ${field(m, 'estado')}',
    idOf: (m) => field(m, 'id'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nuevo despacho',
      path: '/despachos',
      fields: [
        FormFieldDef('ruta', 'Ruta'),
        FormFieldDef('placaVehiculo', 'Placa del vehículo'),
        FormFieldDef('fecha', 'Fecha', type: FieldType.date),
        FormFieldDef('hora', 'Hora', type: FieldType.time),
        FormFieldDef('numeroPasajeros', 'Número de pasajeros', type: FieldType.number),
      ],
    ),
    deleteAction: const DeleteAction(
      label: 'Cancelar',
      message: 'Indica el motivo de la cancelación del despacho.',
      askKey: 'motivo',
      askLabel: 'Motivo',
      askMax: 250,
    ),
  );
}