import 'package:billey/features/speech/domain/transaction_voice_classifier.dart';
import 'package:billey/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classifier = TransactionVoiceClassifier();

  test('classifies common expense phrases', () {
    expect(
      classifier.classify('Me gasté 50 mil en comida'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Compré unos zapatos'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Pagué el recibo de la luz'),
      TransactionType.gasto,
    );
  });

  test('classifies common income phrases', () {
    expect(
      classifier.classify('Hoy me consignaron el sueldo'),
      TransactionType.ingreso,
    );
    expect(
      classifier.classify('Me pagaron 300 mil de un cliente'),
      TransactionType.ingreso,
    );
    expect(
      classifier.classify('Recibí una transferencia'),
      TransactionType.ingreso,
    );
  });

  test('understands the direction of transfers and money movements', () {
    expect(
      classifier.classify('Le envié 100 mil a mi mamá'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Transferí 80 mil a Juan'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Me enviaron 100 mil'),
      TransactionType.ingreso,
    );
    expect(
      classifier.classify('Me abonaron el reembolso'),
      TransactionType.ingreso,
    );
  });

  test('recognizes broader expense and income vocabulary', () {
    expect(
      classifier.classify('Me descontaron la cuota del banco'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Cobré una comisión del cliente'),
      TransactionType.ingreso,
    );
    expect(
      classifier.classify('Doné cincuenta mil'),
      TransactionType.gasto,
    );
  });

  test('leaves an ambiguous phrase unclassified', () {
    expect(classifier.classify('Helados para el equipo'), isNull);
  });

  test('recognizes any conjugation of "ingresar", not just the noun', () {
    expect(classifier.classify('Me ingresó 500 mil'), TransactionType.ingreso);
    expect(
      classifier.classify('Me ingresaron el pago de la factura'),
      TransactionType.ingreso,
    );
    expect(classifier.classify('Ingresé 200 mil hoy'), TransactionType.ingreso);
    expect(
      classifier.classify('Tuve un ingreso de 300 mil'),
      TransactionType.ingreso,
    );
  });

  test('does not confuse the noun "recibo" with the verb "recibir"', () {
    expect(
      classifier.classify('Pagué el recibo del agua'),
      TransactionType.gasto,
    );
  });

  test('does not misfire on unrelated words sharing a verb stem', () {
    expect(
      classifier.classify('Le envié 50 mil a mi hermano'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Transferí 80 mil a Juan'),
      TransactionType.gasto,
    );
    expect(
      classifier.classify('Me transfirieron 150 mil'),
      TransactionType.ingreso,
    );
  });
}
