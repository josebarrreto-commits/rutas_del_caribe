import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.navy,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.turquoise,
          child: Text('RC', style: TextStyle(
            color: AppColors.navy, fontSize: 30, fontWeight: FontWeight.w900)),
        ),
        SizedBox(height: 20),
        Text('RUTAS DEL CARIBE', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold,
          fontSize: 22, letterSpacing: 1.5)),
        SizedBox(height: 8),
        Text('Gestión de transporte', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 30),
        SizedBox(width: 26, height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5, color: AppColors.gold)),
      ]),
    ),
  );
}
