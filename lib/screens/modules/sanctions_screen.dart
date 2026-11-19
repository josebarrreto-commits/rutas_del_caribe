import 'package:flutter/material.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

class SanctionsScreen extends StatelessWidget {
  const SanctionsScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Sanciones',
    description: 'Consulta y gestiona las sanciones aplicadas.',
    icon: Icons.gavel_outlined,
    path: '/sanciones',
    titleOf: (m) => field(m, 'nombresConductor'),
    subtitleOf: (m) =>
        '${field(m, 'estado')} · ${field(m, 'fechaInicio')} a ${field(m, 'fechaFin')}\n${field(m, 'motivo')}',
    idOf: (m) => field(m, 'id'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nueva sanción',
      path: '/sanciones',
      fields: [
        FormFieldDef('identificacionConductor', 'Identificación del conductor'),
        FormFieldDef('motivo', 'Motivo', maxLength: 500, multiline: true),
        FormFieldDef('fechaInicio', 'Fecha de inicio', type: FieldType.date),
        FormFieldDef('fechaFin', 'Fecha de fin', type: FieldType.date),
      ],
    ),
    editFields: const [
      FormFieldDef('motivo', 'Motivo', maxLength: 500, multiline: true),
      FormFieldDef('fechaInicio', 'Fecha de inicio', type: FieldType.date),
      FormFieldDef('fechaFin', 'Fecha de fin', type: FieldType.date),
      FormFieldDef('estado', 'Estado (ACTIVA, CUMPLIDA o ANULADA)'),
    ],
    deleteAction: const DeleteAction(
      label: 'Anular',
      message: '¿Anular esta sanción? Solo se pueden anular las ACTIVAS.',
      useDelete: false,
      putKeys: ['motivo'],
      overrides: {'estado': 'ANULADA'},
    ),
  );
}