import 'package:flutter_test/flutter_test.dart';
import 'package:rutas_del_caribe/main.dart';

void main() {
  testWidgets('La aplicación muestra la pantalla de acceso', (tester) async {
    await tester.pumpWidget(const RutasDelCaribeApp());
    expect(find.text('Rutas del Caribe'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
