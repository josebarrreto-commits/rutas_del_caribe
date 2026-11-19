import 'package:flutter/material.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}
class _RecoveryScreenState extends State<RecoveryScreen> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recuperar contraseña')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const BrandHeader(title: 'Recupera tu acceso', subtitle: 'Te enviaremos un código de verificación'),
        const SizedBox(height: 32),
        TextField(controller: controller, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Correo electrónico o documento',
            prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 20),
        PrimaryButton(text: 'Enviar código', onPressed: () =>
          Navigator.pushNamed(context, AppRoutes.otp)),
      ]),
    ),
  );
}
