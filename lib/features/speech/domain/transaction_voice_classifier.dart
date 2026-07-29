import '../../../models/transaction.dart';

class TransactionVoiceClassifier {
  const TransactionVoiceClassifier();

  TransactionType? classify(String transcript) {
    final text = _normalize(transcript);

    if (_incomePhrases.any(text.contains)) {
      return TransactionType.ingreso;
    }
    if (_expensePhrases.any(text.contains)) {
      return TransactionType.gasto;
    }
    return null;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9ñ]+'), ' ')
      .trim();

  static const _incomePhrases = [
    'me consignaron',
    'me llego',
    'me pagaron',
    'me depositaron',
    'me transfirieron',
    'recibi',
    'cobre',
    'ingreso',
    'sueldo',
    'salario',
    'nomina',
    'venta',
    'reembolso',
    'bono',
    'comision',
  ];

  static const _expensePhrases = [
    'me gaste',
    'gaste',
    'compre',
    'pague',
    'me cobraron',
    'me costo',
    'gasto',
    'compra',
  ];
}
