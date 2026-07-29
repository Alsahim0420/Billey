import 'package:billey/features/speech/domain/income_voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = IncomeVoiceParser();
  final now = DateTime(2026, 7, 29, 22);

  test('requests the salary when it has not been remembered', () {
    final draft = parser.parse(
      'Hoy me consignaron el sueldo',
      now: now,
    );

    expect(draft.source, 'Sueldo');
    expect(draft.amount, isNull);
    expect(draft.requiresRememberedSalary, isTrue);
  });

  test('uses the remembered salary', () {
    final draft = parser.parse(
      'Hoy me llegó el sueldo',
      now: now,
      rememberedSalary: 3000000,
    );

    expect(draft.amount, 3000000);
    expect(draft.requiresRememberedSalary, isFalse);
  });

  test('subtracts a spoken reduction from the remembered salary', () {
    final draft = parser.parse(
      'Hoy me llegó el sueldo pero me llegó 100.000 menos',
      now: now,
      rememberedSalary: 3000000,
    );

    expect(draft.source, 'Sueldo');
    expect(draft.amount, 2900000);
    expect(draft.hasSalaryAdjustment, isTrue);
  });

  test('parses a regular client payment', () {
    final draft = parser.parse(
      'Hoy recibí 450 mil de un cliente',
      now: now,
    );

    expect(draft.source, 'Pago de cliente');
    expect(draft.amount, 450000);
  });
}
