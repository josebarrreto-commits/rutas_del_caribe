import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import 'api_list_view.dart';

class DeleteAction {
  const DeleteAction({
    required this.label,
    required this.message,
    this.useDelete = true,
    this.overrides = const {},
    this.putKeys,
    this.askKey,
    this.askLabel,
    this.askMax,
    this.emptyBody = false,
  });

  final String label;
  final String message;
  final bool useDelete;
  final Map<String, dynamic> overrides;
  final List<String>? putKeys;
  final String? askKey;
  final String? askLabel;
  final int? askMax;
  final bool emptyBody;
}

class ModuleScreen extends StatefulWidget {
  const ModuleScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.path,
    required this.titleOf,
    this.subtitleOf,
    this.formBuilder,
    this.idOf,
    this.editFields,
    this.editValues,
    this.deleteAction,
    this.extraActions = const [],
    this.listQuery = '',
  });

  final String title;
  final String description;
  final IconData icon;
  final String path;
  final ItemText titleOf;
  final ItemText? subtitleOf;
  final WidgetBuilder? formBuilder;
  final ItemText? idOf;
  final List<FormFieldDef>? editFields;
  final Map<String, dynamic> Function(Map<String, dynamic>)? editValues;
  final DeleteAction? deleteAction;
  final List<ItemMenuAction> extraActions;
  final String listQuery;

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  int _reload = 0;

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _newRecord() async {
    if (widget.formBuilder == null) {
      _msg('El formulario se implementará en el siguiente paso.');
      return;
    }
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: widget.formBuilder!),
    );
    if (created == true && mounted) {
      setState(() => _reload++);
      _msg('Registro creado correctamente.');
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final id = widget.idOf?.call(item) ?? '';
    if (id.isEmpty) {
      _msg('No se encontró el identificador del registro.');
      return;
    }
    final values = widget.editValues?.call(item) ?? item;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(
          title: 'Editar registro',
          path: '${widget.path}/${Uri.encodeComponent(id)}',
          fields: widget.editFields!,
          initialValues: values,
          isEdit: true,
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() => _reload++);
      _msg('Registro actualizado correctamente.');
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final a = widget.deleteAction!;
    final id = widget.idOf?.call(item) ?? '';
    if (id.isEmpty) {
      _msg('No se encontró el identificador del registro.');
      return;
    }

    String? text;
    if (a.askKey != null) {
      text = await showDialog<String>(
        context: context,
        builder: (_) => _AskDialog(
          title: a.label,
          message: a.message,
          label: a.askLabel ?? '',
          maxLength: a.askMax,
        ),
      );
      if (text == null) return;
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(a.label),
          content: Text(a.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    final path = '${widget.path}/${Uri.encodeComponent(id)}';
    try {
      if (a.useDelete) {
        Map<String, dynamic>? body;
        if (a.askKey != null) {
          body = {a.askKey!: text};
        } else if (a.emptyBody) {
          body = {};
        }
        await ApiService().delete(path, body: body);
      } else {
        final values = widget.editValues?.call(item) ?? item;
        final body = <String, dynamic>{};
        for (final f in widget.editFields ?? const <FormFieldDef>[]) {
          if (a.putKeys != null && !a.putKeys!.contains(f.key)) continue;
          final v = values[f.key];
          if (v == null || v.toString().isEmpty) continue;
          body[f.key] = f.type == FieldType.date ? formValue(f, v) : v;
        }
        body.addAll(a.overrides);
        await ApiService().put(path, body);
      }
      if (!mounted) return;
      setState(() => _reload++);
      _msg('Listo: ${a.label.toLowerCase()} realizado.');
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
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
            child: Icon(widget.icon, color: AppColors.navy, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        Text(widget.description,
            style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 22),
        Expanded(
          child: ApiListView(
            key: ValueKey(_reload),
            path: widget.path,
            titleOf: widget.titleOf,
            subtitleOf: widget.subtitleOf,
            onEdit: widget.editFields == null ? null : _edit,
            onDelete: widget.deleteAction == null ? null : _delete,
            deleteLabel: widget.deleteAction?.label ?? 'Eliminar',
            extraActions: widget.extraActions,
            listQuery: widget.listQuery,
          ),
        ),
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

class _AskDialog extends StatefulWidget {
  const _AskDialog({
    required this.title,
    required this.message,
    required this.label,
    this.maxLength,
  });

  final String title;
  final String message;
  final String label;
  final int? maxLength;

  @override
  State<_AskDialog> createState() => _AskDialogState();
}

class _AskDialogState extends State<_AskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.message),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ctrl,
          maxLength: widget.maxLength,
          decoration: InputDecoration(labelText: widget.label),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
        ),
      ]),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Volver'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, _ctrl.text.trim());
          }
        },
        child: const Text('Confirmar'),
      ),
    ],
  );
}

enum FieldType { text, number, date, time, bool }

class FormFieldDef {
  const FormFieldDef(
    this.key,
    this.label, {
    this.type = FieldType.text,
    this.required = true,
    this.initial,
    this.maxLength,
    this.multiline = false,
  });

  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final String? initial;
  final int? maxLength;
  final bool multiline;
}

String formValue(FormFieldDef f, dynamic raw) {
  final s = raw.toString();
  if (f.type == FieldType.date && s.length >= 10) return s.substring(0, 10);
  return s;
}

class RecordFormScreen extends StatefulWidget {
  const RecordFormScreen({
    super.key,
    required this.title,
    required this.path,
    required this.fields,
    this.initialValues,
    this.isEdit = false,
  });

  final String title;
  final String path;
  final List<FormFieldDef> fields;
  final Map<String, dynamic>? initialValues;
  final bool isEdit;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, bool> _bools = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      final raw = widget.initialValues?[f.key];
      if (f.type == FieldType.bool) {
        _bools[f.key] =
            raw is bool ? raw : (f.initial == null ? true : f.initial == 'true');
      } else {
        _ctrl[f.key] = TextEditingController(
          text: raw != null ? formValue(f, raw) : (f.initial ?? ''),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate(FormFieldDef f) async {
    final current = DateTime.tryParse(_ctrl[f.key]!.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _ctrl[f.key]!.text =
          '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    }
  }

  Future<void> _pickTime(FormFieldDef f) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      _ctrl[f.key]!.text = '${_two(picked.hour)}:${_two(picked.minute)}:00';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final body = <String, dynamic>{};
    for (final f in widget.fields) {
      if (f.type == FieldType.bool) {
        body[f.key] = _bools[f.key];
        continue;
      }
      final text = _ctrl[f.key]!.text.trim();
      if (text.isEmpty) continue;
      body[f.key] = f.type == FieldType.number ? num.parse(text) : text;
    }

    setState(() => _saving = true);
    try {
      if (widget.isEdit) {
        await ApiService().put(widget.path, body);
      } else {
        await ApiService().post(widget.path, body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildField(FormFieldDef f) {
    final label = f.label + (f.required ? '' : ' (opcional)');
    switch (f.type) {
      case FieldType.bool:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(f.label),
          value: _bools[f.key]!,
          onChanged: (v) => setState(() => _bools[f.key] = v),
        );
      case FieldType.date:
      case FieldType.time:
        return TextFormField(
          controller: _ctrl[f.key],
          readOnly: true,
          onTap: () => f.type == FieldType.date ? _pickDate(f) : _pickTime(f),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(f.type == FieldType.date
                ? Icons.calendar_today_outlined
                : Icons.access_time),
          ),
          validator: (v) =>
              f.required && (v == null || v.isEmpty) ? 'Obligatorio' : null,
        );
      case FieldType.number:
        return TextFormField(
          controller: _ctrl[f.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return f.required ? 'Obligatorio' : null;
            return num.tryParse(t) == null ? 'Debe ser un número' : null;
          },
        );
      case FieldType.text:
        return TextFormField(
          controller: _ctrl[f.key],
          maxLength: f.maxLength,
          maxLines: f.multiline ? 3 : 1,
          decoration: InputDecoration(labelText: label),
          validator: (v) => f.required && (v == null || v.trim().isEmpty)
              ? 'Obligatorio'
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(children: [
          for (final f in widget.fields) ...[
            _buildField(f),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ]),
      ),
    ),
  );
}List<ItemMenuAction> activeToggleActions({
  required String path,
  required String noun,
  required String Function(Map<String, dynamic>) idOf,
  required List<FormFieldDef> editFields,
  Map<String, dynamic> Function(Map<String, dynamic>)? editValues,
}) {
  Future<void> change(
    BuildContext context,
    Map<String, dynamic> item,
    bool active,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final id = idOf(item);
    if (id.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se encontró el identificador del registro.'),
        ),
      );
      return;
    }

    final verb = active ? 'Activar' : 'Desactivar';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$verb $noun'),
        content: Text(
          active
              ? '¿Activar este $noun? Volverá a estar disponible.'
              : '¿Desactivar este $noun? No se borra, queda inactivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(verb),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final values = editValues?.call(item) ?? item;
    final body = <String, dynamic>{};
    for (final f in editFields) {
      final v = values[f.key];
      if (v == null || v.toString().isEmpty) continue;
      body[f.key] = f.type == FieldType.date ? formValue(f, v) : v;
    }
    body['activo'] = active;

    try {
      await ApiService().put('$path/${Uri.encodeComponent(id)}', body);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            active ? 'Activado correctamente.' : 'Desactivado correctamente.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  return [
    ItemMenuAction(
      'Desactivar',
      (context, item) => change(context, item, false),
      icon: Icons.block,
      visibleWhen: (m) => m['activo'] != false,
    ),
    ItemMenuAction(
      'Activar',
      (context, item) => change(context, item, true),
      icon: Icons.check_circle_outline,
      visibleWhen: (m) => m['activo'] == false,
    ),
  ];
}