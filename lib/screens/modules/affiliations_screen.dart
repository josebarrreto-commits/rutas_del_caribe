import 'package:flutter/material.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

const _fields = [
  FormFieldDef('identificacionAsociado', 'Identificación del asociado'),
  FormFieldDef('placaVehiculo', 'Placa del vehículo'),
  FormFieldDef('fechaAfiliacion', 'Fecha de afiliación', type: FieldType.date),
  FormFieldDef('fechaFinAfiliacion', 'Fecha fin', type: FieldType.date, required: false),
  FormFieldDef('estado', 'Estado', initial: 'ACTIVA'),
];

class AffiliationsScreen extends StatelessWidget {
  const AffiliationsScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Afiliaciones',
    description: 'Consulta y gestiona las afiliaciones de asociados.',
    icon: Icons.assignment_ind_outlined,
    path: '/afiliaciones',
    titleOf: (m) => '${field(m, 'placaVehiculo')} · ${field(m, 'identificacionAsociado')}',
    subtitleOf: (m) => '${field(m, 'estado')}  ${field(m, 'fechaAfiliacion')}',
    idOf: (m) => field(m, 'id'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nueva afiliación',
      path: '/afiliaciones',
      fields: _fields,
    ),
    editFields: _fields,
    deleteAction: const DeleteAction(
      label: 'Finalizar',
      message: '¿Finalizar esta afiliación? Se conserva el historial.',
      emptyBody: true,
    ),
  );
}