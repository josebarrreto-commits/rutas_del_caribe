import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/module_card.dart';
import '../../widgets/api_list_view.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

void _logout(BuildContext context) {
  ApiService().token = null;
  ApiService().rol = null;
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    ApiService().onUnauthorized = _sessionExpired;
  }

  @override
  void dispose() {
    ApiService().onUnauthorized = null;
    super.dispose();
  }

  void _sessionExpired() {
    if (_expired || !mounted) return;
    _expired = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu sesión venció. Inicia sesión de nuevo.')),
    );
    _logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final rol = ApiService().rol ?? '';

    if (rol == 'ASOCIADO') {
      return const MyAccountScreen();
    }

    final modules = <(String, String, IconData, String)>[
      ('Asociados', 'Registro y consulta', Icons.groups_outlined, AppRoutes.associates),
      ('Afiliaciones', 'Vinculación', Icons.assignment_ind_outlined, AppRoutes.affiliations),
      ('Conductores', 'Personal operativo', Icons.badge_outlined, AppRoutes.drivers),
      ('Vehículos', 'Parque automotor', Icons.directions_bus_outlined, AppRoutes.vehicles),
      ('Tarifas', 'Precios del servicio', Icons.payments_outlined, AppRoutes.fares),
      ('Planillas', 'Control de pasajeros', Icons.receipt_long_outlined, AppRoutes.planillas),
      ('Despachos', 'Salidas programadas', Icons.departure_board_outlined, AppRoutes.dispatches),
      ('Sanciones', 'Registro y seguimiento', Icons.gavel_outlined, AppRoutes.sanctions),
    ];

    final visible = rol == 'ASISTENTE'
        ? modules.where((m) => m.$4 != AppRoutes.fares).toList()
        : modules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas del Caribe'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PANEL PRINCIPAL', style: TextStyle(color: AppColors.gold, letterSpacing: 1.4, fontSize: 11)),
                SizedBox(height: 8),
                Text('Bienvenido', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Administra la operación de tu cooperativa.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Módulos de gestión', style: TextStyle(
              color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: visible.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.12),
                itemBuilder: (context, index) {
                  final item = visible[index];
                  return ModuleCard(title: item.$1, description: item.$2, icon: item.$3,
                    onTap: () => Navigator.pushNamed(context, item.$4));
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

String _conductor(Map<String, dynamic> m) {
  final c = m['conductor'];
  return c is Map ? (c['Nombre del conductor'] ?? '').toString() : '';
}

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Vehículos'),
            Tab(text: 'Viajes'),
            Tab(text: 'Despachos'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ApiListView(
              path: '/mi-cuenta/vehiculos',
              titleOf: (m) => field(m, 'placa'),
              subtitleOf: (m) =>
                  '${field(m, 'tipo')} · ${field(m, 'marca')} ${field(m, 'modelo')}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ApiListView(
              path: '/mi-cuenta/viajes',
              titleOf: (m) =>
                  'Planilla ${field(m, 'numero')} · ${field(m, 'placaVehiculo')}',
              subtitleOf: (m) {
                final conductor = _conductor(m);
                return '${field(m, 'fecha')} · ${field(m, 'estado')} · Pago ${field(m, 'estadoPago')}'
                    '${conductor.isEmpty ? '' : '\nConductor: $conductor'}';
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ApiListView(
              path: '/mi-cuenta/despachos',
              titleOf: (m) =>
                  '${field(m, 'ruta')} · ${field(m, 'placaVehiculo')}',
              subtitleOf: (m) =>
                  '${field(m, 'fecha')} ${field(m, 'hora')} · ${field(m, 'estado')}',
            ),
          ),
        ],
      ),
    ),
  );
}