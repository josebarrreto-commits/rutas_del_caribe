import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../widgets/api_list_view.dart';
import '../../widgets/module_screen.dart';

const _editFields = [
  FormFieldDef('nombres', 'Nombres'),
  FormFieldDef('fechaNacimiento', 'Fecha de nacimiento', type: FieldType.date, required: false),
  FormFieldDef('celular', 'Celular', required: false),
  FormFieldDef('correo', 'Correo', required: false),
  FormFieldDef('fechaIngreso', 'Fecha de ingreso', type: FieldType.date, required: false),
  FormFieldDef('activo', 'Activo', type: FieldType.bool),
];

class _CredentialDialog extends StatefulWidget {
  const _CredentialDialog({
    required this.user,
    required this.pass,
    required this.raw,
  });

  final String user;
  final String pass;
  final String raw;

  @override
  State<_CredentialDialog> createState() => _CredentialDialogState();
}

class _CredentialDialogState extends State<_CredentialDialog> {
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  String? _hint;

  @override
  void initState() {
    super.initState();
    _userCtrl = TextEditingController(text: widget.user);
    _passCtrl = TextEditingController(text: widget.pass);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _copy(
    TextEditingController ctrl,
    FocusNode focus,
    String label,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: ctrl.text));
      if (!mounted) return;
      setState(() => _hint = '$label copiado al portapapeles.');
    } catch (_) {
      focus.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.selection =
            TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
      });
      if (!mounted) return;
      setState(() =>
          _hint = '$label seleccionado. Presiona Ctrl+C para copiarlo.');
    }
  }

  Widget _row(
    String label,
    TextEditingController ctrl,
    FocusNode focus,
  ) =>
      TextField(
        controller: ctrl,
        focusNode: focus,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            tooltip: 'Copiar',
            icon: const Icon(Icons.copy),
            onPressed: () => _copy(ctrl, focus, label),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hasData = widget.user.isNotEmpty && widget.pass.isNotEmpty;
    return AlertDialog(
      title: const Text('Credencial temporal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entrégala al asociado. No se volverá a mostrar.'),
            const SizedBox(height: 16),
            if (hasData) ...[
              _row('Usuario', _userCtrl, _userFocus),
              const SizedBox(height: 12),
              _row('Clave temporal', _passCtrl, _passFocus),
              if (_hint != null) ...[
                const SizedBox(height: 12),
                Text(_hint!, style: const TextStyle(fontSize: 12)),
              ],
            ] else
              SelectableText(widget.raw),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

Future<void> _generarCredencial(
    BuildContext context, Map<String, dynamic> item) async {
  final id = field(item, 'identificacion');
  final messenger = ScaffoldMessenger.of(context);

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Generar credencial'),
      content: Text(
        'Se generará una clave temporal para el asociado $id. '
        'Si ya tenía una, dejará de funcionar. '
        'La clave se muestra una sola vez.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Generar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  try {
    final res = await ApiService().post(
      '/asociados/${Uri.encodeComponent(id)}/credencial-temporal',
      {},
    );
    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : (res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{});

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CredentialDialog(
        user: field(data, 'username'),
        pass: field(data, 'passwordTemporal'),
        raw: res.toString(),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }
}

class AssociatesScreen extends StatelessWidget {
  const AssociatesScreen({super.key});

  @override
  Widget build(BuildContext context) => ModuleScreen(
    title: 'Asociados',
    description: 'Administra la información de los asociados de la cooperativa.',
    icon: Icons.groups_outlined,
    path: '/asociados',
    titleOf: (m) => field(m, 'nombres'),
    subtitleOf: (m) =>
        'CC ${field(m, 'identificacion')} · ${m['activo'] == false ? 'Inactivo' : 'Activo'} · ${field(m, 'estadoCredencial')}',
    idOf: (m) => field(m, 'identificacion'),
    formBuilder: (_) => const RecordFormScreen(
      title: 'Nuevo asociado',
      path: '/asociados',
      fields: [
        FormFieldDef('identificacion', 'Identificación'),
        ..._editFields,
      ],
    ),
    editFields: _editFields,
       extraActions: [
      ItemMenuAction(
        'Generar credencial',
        _generarCredencial,
        icon: Icons.vpn_key_outlined,
      ),
      ...activeToggleActions(
        path: '/asociados',
        noun: 'asociado',
        idOf: (m) => field(m, 'identificacion'),
        editFields: _editFields,
      ),
    ],
  );
}