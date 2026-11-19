import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _api = ApiService();
  final SessionService _session = SessionService();

  late final AuthService _auth;

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth = AuthService(_api);
  }

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final documento = _documentController.text.trim();
    final password = _passwordController.text;

    if (documento.isEmpty || password.isEmpty) {
      _showMessage('Ingresa documento y contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _api.token = null;
      _api.rol = null;

      final response = await _auth.login(
        username: documento,
        password: password,
      );

      if (response is! Map || response['token'] is! String) {
        throw Exception('La API no devolvió un token válido.');
      }

      final String token = response['token'];
      if (token.isEmpty) {
        throw Exception('El token recibido está vacío.');
      }

      final bool mustChangePassword =
          response['requiereCambioPassword'] == true;
      final String rol = (response['rol'] ?? '').toString();

      _api.token = token;
      _api.rol = rol;

      if (!mounted) return;

      if (mustChangePassword) {
        _showMessage(
          'Debes cambiar tu contraseña temporal para continuar.',
          color: Colors.orange,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.changePassword);
        return;
      }

      await _session.saveToken(token);

      if (!mounted) return;

      _showMessage('Inicio de sesión exitoso.', color: Colors.green);
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo iniciar sesión: ${e.message}',
          color: Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(
                    title: 'Rutas del Caribe',
                    subtitle: 'Gestión de transporte',
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa con tus credenciales para continuar.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _documentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Documento / usuario',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.recovery);
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: _isLoading ? 'Verificando...' : 'Iniciar sesión',
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'COOPERATIVA · RUTAS DEL CARIBE',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}