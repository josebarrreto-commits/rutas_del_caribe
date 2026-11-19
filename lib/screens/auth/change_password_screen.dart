import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final pass = TextEditingController();
  final confirm = TextEditingController();

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
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  void _showMessage(String text, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  String? _validate(String password, String confirmation) {
    if (password.isEmpty || confirmation.isEmpty) {
      return 'Completa los dos campos.';
    }
    if (password != confirmation) {
      return 'Verifica que las contraseñas coincidan.';
    }
    if (password.length < 12) {
      return 'La contraseña debe tener al menos 12 caracteres.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Debe incluir una mayúscula, una minúscula y un número.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_isLoading) return;

    final error = _validate(pass.text, confirm.text);
    if (error != null) {
      _showMessage(error);
      return;
    }

    if (_api.token == null) {
      _showMessage(
        'Inicia sesión con tu clave temporal para poder cambiarla.',
        color: Colors.orange,
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _auth.changePassword(
        nuevaPassword: pass.text,
        confirmacionPassword: confirm.text,
      );

      if (response is! Map ||
          response['token'] is! String ||
          (response['token'] as String).isEmpty) {
        throw Exception('La API no devolvió un token válido.');
      }

      final String token = response['token'];
      _api.token = token;
      _api.rol = (response['rol'] ?? _api.rol ?? '').toString();
      await _session.saveToken(token);

      if (!mounted) return;

      _showMessage('Contraseña actualizada correctamente.',
          color: Colors.green);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.dashboard, (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, color: Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'No se pudo cambiar la contraseña. Revisa tu conexión e inténtalo de nuevo.',
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Crear nueva contraseña')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Text(
          'Mínimo 12 caracteres, con mayúscula, minúscula y número.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: pass,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Nueva contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirm,
          obscureText: _obscure,
          decoration: const InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icon(Icons.lock_reset),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: _isLoading ? 'Guardando...' : 'Guardar contraseña',
          onPressed: _save,
        ),
      ]),
    ),
  );
}