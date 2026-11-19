import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';

typedef ItemText = String Function(Map<String, dynamic> item);
typedef ItemAction = void Function(Map<String, dynamic> item);

class ItemMenuAction {
  const ItemMenuAction(
    this.label,
    this.run, {
    this.icon = Icons.more_horiz,
    this.visibleWhen,
  });

  final String label;
  final IconData icon;
  final bool Function(Map<String, dynamic> item)? visibleWhen;
  final Future<void> Function(BuildContext context, Map<String, dynamic> item)
      run;
}

String field(Map<String, dynamic> m, String key) {
  final v = m[key];
  return v == null ? '' : v.toString();
}

class ApiListView extends StatefulWidget {
  const ApiListView({
    super.key,
    required this.path,
    required this.titleOf,
    this.subtitleOf,
    this.onEdit,
    this.onDelete,
    this.deleteLabel = 'Eliminar',
    this.extraActions = const [],
    this.listQuery = '',
  });

  final String path;
  final ItemText titleOf;
  final ItemText? subtitleOf;
  final ItemAction? onEdit;
  final ItemAction? onDelete;
  final String deleteLabel;
  final List<ItemMenuAction> extraActions;
  final String listQuery;

  @override
  State<ApiListView> createState() => _ApiListViewState();
}

class _ApiListViewState extends State<ApiListView> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final extra = widget.listQuery.isEmpty ? '' : '&${widget.listQuery}';
    final data =
        await ApiService().get('${widget.path}?page=1&pageSize=50$extra');
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final inner = data['data'];
      if (inner is List) {
        items = inner;
      } else if (inner is Map && inner['items'] is List) {
        items = inner['items'] as List;
      }
    }
    debugPrint('[ApiListView] ${widget.path}: ${items.length} registros');
    if (items.isEmpty) debugPrint('[ApiListView] respuesta cruda: $data');
    if (items.isNotEmpty) debugPrint('[ApiListView] ejemplo: ${items.first}');
    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _runAction(
    ItemMenuAction action,
    Map<String, dynamic> item,
  ) async {
    await action.run(context, item);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ruta pedida: ${widget.path}\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _refresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Sin registros'));
        }

        final hasActions = widget.onEdit != null ||
            widget.onDelete != null ||
            widget.extraActions.isNotEmpty;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = Map<String, dynamic>.from(items[i] as Map);
              final subtitle = widget.subtitleOf?.call(item) ?? '';
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        widget.titleOf(item),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    ),
                    if (hasActions)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 4,
                          children: [
                            for (final action in widget.extraActions)
                              if (action.visibleWhen == null ||
                                  action.visibleWhen!(item))
                                TextButton.icon(
                                  onPressed: () => _runAction(action, item),
                                  icon: Icon(action.icon, size: 18),
                                  label: Text(action.label),
                                ),
                            if (widget.onEdit != null)
                              TextButton.icon(
                                onPressed: () => widget.onEdit!(item),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Editar'),
                              ),
                            if (widget.onDelete != null)
                              TextButton.icon(
                                onPressed: () => widget.onDelete!(item),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: Text(widget.deleteLabel),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}