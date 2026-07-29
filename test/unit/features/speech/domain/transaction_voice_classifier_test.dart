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

  test('leaves an ambiguous phrase unclassified', () {
    expect(classifier.classify('Helados para el equipo'), isNull);
  });
}
