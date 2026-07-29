import 'package:billey/features/speech/domain/expense_voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = ExpenseVoiceParser();
  final now = DateTime(2026, 7, 28, 22, 0);

  test('extracts a Colombian amount and food category from words', () {
    final draft = parser.parse(
      'Me gasté doscientos mil en la comida',
      now: now,
    );

    expect(draft.amount, 200000);
    expect(draft.title, 'Comida');
    expect(draft.categoryId, 'food');
    expect(draft.date, DateTime(2026, 7, 28));
  });

  test('extracts an amount using Colombian separators', () {
    final draft = parser.parse(
      'Pagué 45.000 de gasolina ayer',
      now: now,
    );

    expect(draft.amount, 45000);
    expect(draft.title, 'Gasolina');
    expect(draft.categoryId, 'transport');
    expect(draft.date, DateTime(2026, 7, 27));
  });

  test('matches a user category by name', () {
    final draft = parser.parse(
      'Gasté 80 mil en mascotas',
      now: now,
      customCategories: const {'pets': 'Mascotas'},
    );

    expect(draft.amount, 80000);
    expect(draft.categoryId, 'pets');
  });
}
