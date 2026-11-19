import 'package:flutter/material.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

const _editFields = [
  FormFieldDef('nombres', 'Nombres'),
  FormFieldDef('fechaNacimiento', 'Fecha de nacimiento', type: FieldType.date),
  FormFieldDef('numeroLicencia', 'Número de licencia'),
  FormFieldDef('categoriaLicencia', 'Categoría de licencia (ej. C2)'),
  FormFieldDef('vigenciaLicencia', 'Vigencia de la licencia', type: FieldType.date),
  FormFieldDef('celular', 'Celular', required: false),
  FormFieldDef('correo', 'Correo', required: false),
  FormFieldDef('activo', 'Activo', type: FieldType.bool),
];

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Conductores',
    description: 'Consulta y gestiona los conductores de la cooperativa.',
    icon: Icons.badge_outlined,
    path: '/conductores',
    titleOf: (m) => field(m, 'nombres'),
    subtitleOf: (m) =>
        'CC ${field(m, 'identificacion')} · Licencia ${field(m, 'categoriaLicencia')} · ${m['activo'] == false ? 'Inactivo' : 'Activo'}',
    idOf: (m) => field(m, 'identificacion'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nuevo conductor',
      path: '/conductores',
      fields: [
        FormFieldDef('identificacion', 'Identificación'),
        ..._editFields,
      ],
    ),
    editFields: _editFields,
    extraActions: activeToggleActions(
      path: '/conductores',
      noun: 'conductor',
      idOf: (m) => field(m, 'identificacion'),
      editFields: _editFields,
    ),
  );
}