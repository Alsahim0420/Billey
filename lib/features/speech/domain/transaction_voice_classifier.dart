import '../../../models/transaction.dart';

class TransactionVoiceClassifier {
  const TransactionVoiceClassifier();

  TransactionType? classify(String transcript) {
    final text = _normalize(transcript);

    if (_incomingMoney.hasMatch(text)) {
      return TransactionType.ingreso;
    }
    if (_outgoingMoney.hasMatch(text)) {
      return TransactionType.gasto;
    }

    final incomeScore =
        _incomeSignals.where((signal) => text.contains(signal)).length;
    final expenseScore =
        _expenseSignals.where((signal) => text.contains(signal)).length;
    if (incomeScore > expenseScore) return TransactionType.ingreso;
    if (expenseScore > incomeScore) return TransactionType.gasto;

    if (_looksLikePurchase.hasMatch(text)) return TransactionType.gasto;
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

  static final _incomingMoney = RegExp(
    r'\b(?:me|nos)\s+(?:consignaron|pagaron|depositaron|transfirieron|enviaron|mandaron|giraron|abonaron|devolvieron|reembolsaron|prestaron|regalaron|dieron|llego|llegaron)\b'
    r'|\b(?:recibi|recibimos|cobre|cobramos|gane|ganamos)\b',
  );

  static final _outgoingMoney = RegExp(
    r'\b(?:le|les)\s+(?:envie|enviamos|mande|mandamos|consigne|consignamos|transferi|transferimos|pague|pagamos|preste|prestamos|regale|regalamos|devolvi|devolvimos|abone|abonamos)\b'
    r'|\b(?:envie|enviamos|mande|mandamos|consigne|consignamos|transferi|transferimos|pague|pagamos|gaste|gastamos|compre|compramos|preste|prestamos|regale|regalamos|done|donamos|retire|retiramos|saque|sacamos|inverti|invertimos)\b'
    r'|\bme\s+(?:cobraron|descontaron|debitaron|quitaron|costo)\b',
  );

  static final _looksLikePurchase = RegExp(
    r'\b(?:mercado|comida|restaurante|transporte|taxi|uber|gasolina|factura|recibo|arriendo|alquiler|cuota|servicio|medicina|curso|ropa|zapatos)\b',
  );

  static const _incomeSignals = [
    'ingreso',
    'sueldo',
    'salario',
    'nomina',
    'venta',
    'cliente',
    'reembolso',
    'bono',
    'comision',
    'ganancia',
    'rendimiento',
    'intereses',
    'dividendo',
    'propina',
    'premio',
    'devolucion',
  ];

  static const _expenseSignals = [
    'gasto',
    'compra',
    'pago',
    'costo',
    'cobro',
    'deuda',
    'factura',
    'recibo',
    'cuota',
    'donacion',
  ];
}
