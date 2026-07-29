import 'package:billey/models/transaction.dart';
import 'package:billey/services/voice_expense_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceExpenseParser', () {
    test('parses amount and food category in Spanish', () {
      final result = VoiceExpenseParser.parse(
        'Gasté 25000 en comida del supermercado',
      );

      expect(result.amount, 25000);
      expect(result.category, TransactionCategory.food);
      expect(result.type, TransactionType.gasto);
      expect(result.title, isNotNull);
      expect(result.canSaveExpense, isTrue);
    });

    test('parses thousands with mil suffix', () {
      final result = VoiceExpenseParser.parse('Pagué 25 mil de taxi');

      expect(result.amount, 25000);
      expect(result.category, TransactionCategory.transport);
    });

    test('parses decimal amount', () {
      final result = VoiceExpenseParser.parse('Son 45.50 en el café');

      expect(result.amount, closeTo(45.5, 0.01));
      expect(result.category, TransactionCategory.food);
    });
  });
}
