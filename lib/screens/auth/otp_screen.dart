import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}
class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verificación OTP')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Verifica tu identidad', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ingresa el código que recibiste para continuar.'),
        const SizedBox(height: 24),
        TextField(controller: controller, keyboardType: TextInputType.number,
          maxLength: 6, decoration: const InputDecoration(labelText: 'Código de 6 dígitos')),
        const SizedBox(height: 12),
        PrimaryButton(text: 'Verificar código', onPressed: () =>
          Navigator.pushNamed(context, AppRoutes.changePassword)),
      ]),
    ),
  );
}
