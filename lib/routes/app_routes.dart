import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/recovery_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/modules/associates_screen.dart';
import '../screens/modules/affiliations_screen.dart';
import '../screens/modules/drivers_screen.dart';
import '../screens/modules/vehicles_screen.dart';
import '../screens/modules/fares_screen.dart';
import '../screens/modules/planillas_screen.dart';
import '../screens/modules/dispatches_screen.dart';
import '../screens/modules/sanctions_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const recovery = '/recovery';
  static const otp = '/otp';
  static const changePassword = '/change-password';
  static const dashboard = '/dashboard';
  static const associates = '/associates';
  static const affiliations = '/affiliations';
  static const drivers = '/drivers';
  static const vehicles = '/vehicles';
  static const routes = '/routes';
  static const fares = '/fares';
  static const planillas = '/planillas';
  static const dispatches = '/dispatches';
  static const sanctions = '/sanctions';

  static Map<String, WidgetBuilder> get allRoutes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    recovery: (_) => const RecoveryScreen(),
    otp: (_) => const OtpScreen(),
    changePassword: (_) => const ChangePasswordScreen(),
    dashboard: (_) => const DashboardScreen(),
    associates: (_) => const AssociatesScreen(),
    affiliations: (_) => const AffiliationsScreen(),
    drivers: (_) => const DriversScreen(),
    vehicles: (_) => const VehiclesScreen(),
    fares: (_) => const FaresScreen(),
    planillas: (_) => const PlanillasScreen(),
    dispatches: (_) => const DispatchesScreen(),
    sanctions: (_) => const SanctionsScreen(),
  };
}
