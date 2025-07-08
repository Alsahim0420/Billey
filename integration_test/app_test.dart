import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_finances_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should start with splash screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar que se muestra la pantalla de splash
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should navigate to main navigation after splash',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que termine la animación del splash
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que se muestra la navegación principal
      expect(find.byType(BottomAppBar), findsOneWidget);
    });

    testWidgets('should display all navigation tabs',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que se muestran todos los tabs
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Lista'), findsOneWidget);
      expect(find.text('Gráficos'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navegar a la lista de transacciones
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      // Verificar que se muestra la pantalla de lista
      expect(find.text('Lista de Transacciones'), findsOneWidget);

      // Navegar a gráficos
      await tester.tap(find.text('Gráficos'));
      await tester.pumpAndSettle();

      // Verificar que se muestra la pantalla de gráficos
      expect(find.text('Resumen Mensual'), findsOneWidget);
    });

    testWidgets('should open add transaction screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tocar el botón flotante
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que se abre la pantalla de agregar transacción
      expect(find.text('Agregar Transacción'), findsOneWidget);
    });

    testWidgets('should display add transaction form fields',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Abrir pantalla de agregar transacción
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que se muestran los campos del formulario
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Monto'), findsOneWidget);
      expect(find.text('Fecha'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
    });

    testWidgets('should open settings menu', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tocar el botón de ajustes
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();

      // Verificar que se abre el menú de ajustes
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Gestionar Categorías'), findsOneWidget);
      expect(find.text('Exportar Datos'), findsOneWidget);
      expect(find.text('Compartir App'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);
    });

    testWidgets('should open categories management',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Abrir ajustes
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();

      // Tocar gestionar categorías
      await tester.tap(find.text('Gestionar Categorías'));
      await tester.pumpAndSettle();

      // Verificar que se abre la pantalla de gestión de categorías
      expect(find.text('Gestionar Categorías'), findsOneWidget);
    });

    testWidgets('should display about dialog', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Abrir ajustes
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();

      // Tocar acerca de
      await tester.tap(find.text('Acerca de'));
      await tester.pumpAndSettle();

      // Verificar que se muestra el diálogo
      expect(find.text('My Finances'), findsOneWidget);
      expect(find.text('Versión 1.0.0'), findsOneWidget);
    });

    testWidgets('should display empty state when no transactions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que se muestra el estado vacío
      expect(find.text('No hay transacciones'), findsOneWidget);
      expect(find.text('Agrega tu primera transacción'), findsOneWidget);
    });

    testWidgets('should display floating action button',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que se muestra el botón flotante
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should have proper app structure',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar la estructura básica de la app
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should handle navigation properly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que la navegación funciona correctamente
      expect(find.text('Inicio'), findsOneWidget);

      // Navegar a lista
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      expect(find.text('Lista de Transacciones'), findsOneWidget);

      // Navegar a gráficos
      await tester.tap(find.text('Gráficos'));
      await tester.pumpAndSettle();
      expect(find.text('Resumen Mensual'), findsOneWidget);

      // Volver a inicio
      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
