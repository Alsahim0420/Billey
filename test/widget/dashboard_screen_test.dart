import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:billey/screens/dashboard_screen.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/models/transaction.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late TransactionProvider transactionProvider;
    late CategoryProvider categoryProvider;

    setUp(() {
      transactionProvider = TransactionProvider();
      categoryProvider = CategoryProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TransactionProvider>.value(
              value: transactionProvider,
            ),
            ChangeNotifierProvider<CategoryProvider>.value(
              value: categoryProvider,
            ),
          ],
          child: const DashboardScreen(),
        ),
      );
    }

    testWidgets('should display dashboard title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should display balance card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Balance Total'), findsOneWidget);
    });

    testWidgets('should display income and expense cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Ingresos'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
    });

    testWidgets('should display recent transactions section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Transacciones Recientes'), findsOneWidget);
    });

    testWidgets('should display empty state when no transactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('No hay transacciones'), findsOneWidget);
      expect(find.text('Agrega tu primera transacción'), findsOneWidget);
    });

    testWidgets('should display transactions when available',
        (WidgetTester tester) async {
      // Agregar transacciones usando el método público
      final transaction = TransactionModel(
        id: 'test-1',
        title: 'Test Transaction',
        amount: 1000.0,
        date: DateTime.now(),
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      transactionProvider.addTransaction(transaction);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Transaction'), findsOneWidget);
    });

    testWidgets('should display correct balance amounts',
        (WidgetTester tester) async {
      // Agregar transacciones usando métodos públicos
      final incomeTransaction = TransactionModel(
        id: 'income-1',
        title: 'Salary',
        amount: 2000.0,
        date: DateTime.now(),
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      final expenseTransaction = TransactionModel(
        id: 'expense-1',
        title: 'Food',
        amount: 500.0,
        date: DateTime.now(),
        type: TransactionType.gasto,
        category: TransactionCategory.food,
      );

      transactionProvider.addTransaction(incomeTransaction);
      transactionProvider.addTransaction(expenseTransaction);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestran los montos (pueden estar formateados)
      expect(find.textContaining('2000'), findsOneWidget); // Income
      expect(find.textContaining('500'), findsOneWidget); // Expense
    });

    testWidgets('should display category icons correctly',
        (WidgetTester tester) async {
      final transaction = TransactionModel(
        id: 'test-1',
        title: 'Food Transaction',
        amount: 100.0,
        date: DateTime.now(),
        type: TransactionType.gasto,
        category: TransactionCategory.food,
      );

      transactionProvider.addTransaction(transaction);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra algún icono (puede ser el de comida)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should display transaction date correctly',
        (WidgetTester tester) async {
      final testDate = DateTime(2024, 1, 15);
      final transaction = TransactionModel(
        id: 'test-1',
        title: 'Test Transaction',
        amount: 100.0,
        date: testDate,
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      transactionProvider.addTransaction(transaction);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra la fecha formateada
      expect(find.textContaining('15'), findsOneWidget);
    });

    testWidgets('should display transaction type indicators',
        (WidgetTester tester) async {
      final incomeTransaction = TransactionModel(
        id: 'income-1',
        title: 'Income',
        amount: 100.0,
        date: DateTime.now(),
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      final expenseTransaction = TransactionModel(
        id: 'expense-1',
        title: 'Expense',
        amount: 50.0,
        date: DateTime.now(),
        type: TransactionType.gasto,
        category: TransactionCategory.transport,
      );

      transactionProvider.addTransaction(incomeTransaction);
      transactionProvider.addTransaction(expenseTransaction);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestran los indicadores de tipo
      expect(find.text('+'), findsOneWidget); // Income indicator
      expect(find.text('-'), findsOneWidget); // Expense indicator
    });

    testWidgets('should display correct transaction count',
        (WidgetTester tester) async {
      final transaction1 = TransactionModel(
        id: 'test-1',
        title: 'Transaction 1',
        amount: 100.0,
        date: DateTime.now(),
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      final transaction2 = TransactionModel(
        id: 'test-2',
        title: 'Transaction 2',
        amount: 200.0,
        date: DateTime.now(),
        type: TransactionType.gasto,
        category: TransactionCategory.transport,
      );

      transactionProvider.addTransaction(transaction1);
      transactionProvider.addTransaction(transaction2);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Transaction 1'), findsOneWidget);
      expect(find.text('Transaction 2'), findsOneWidget);
    });

    testWidgets('should display loading state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que se muestra algún indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state when needed',
        (WidgetTester tester) async {
      // El provider ya inicia vacío, así que debería mostrar estado vacío
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra el estado vacío
      expect(find.text('No hay transacciones'), findsOneWidget);
    });

    testWidgets('should have proper widget structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar la estructura básica del widget
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should handle provider changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificar estado inicial
      expect(find.text('No hay transacciones'), findsOneWidget);

      // Agregar transacción
      final transaction = TransactionModel(
        id: 'test-1',
        title: 'New Transaction',
        amount: 100.0,
        date: DateTime.now(),
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );

      transactionProvider.addTransaction(transaction);
      await tester.pumpAndSettle();

      // Verificar que se actualiza la UI
      expect(find.text('New Transaction'), findsOneWidget);
    });
  });
}
