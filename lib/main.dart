import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RutasDelCaribeApp());
}

class RutasDelCaribeApp extends StatelessWidget {
  const RutasDelCaribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutas del Caribe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.allRoutes,
    );
  }
}
