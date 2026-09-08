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

  // "Me/nos <verbo>" siempre indica dinero que entra, sin importar qué otras
  // palabras acompañen la frase (ej. "me ingresaron el pago de la factura").
  static final _incomingMoney = RegExp(
    r'\b(?:me|nos)\s+(?:consign\w*|pag\w*|deposit\w*|transfir\w*|transfer\w*|envi\w*|mand\w*|gir\w*|abon\w*|devolv\w*|reembols\w*|prest\w*|regal\w*|dier\w*|dio|lleg\w*|ingres\w*|acredit\w*|liquid\w*|cancel\w*)\b'
    // Formas explícitas (no comodín) para evitar falsos positivos con
    // palabras no monetarias que comparten la misma raíz, ej. "recibo"
    // (el sustantivo), "vendaje", "ganga".
    r'|\b(?:recibi|recibimos|recibieron|cobre|cobramos|gane|ganamos|ganaron|vendi|vendimos|vendieron|ingres\w*)\b',
  );

  // "Le/les <verbo>" o el verbo solo (sin "me/nos" antes) indica dinero que
  // sale de tu bolsillo.
  static final _outgoingMoney = RegExp(
    r'\b(?:le|les)\s+(?:envi\w*|mand\w*|consign\w*|transfir\w*|transfer\w*|pag\w*|prest\w*|regal\w*|devolv\w*|abon\w*)\b'
    r'|\b(?:envi\w*|mand\w*|consign\w*|transfir\w*|transfer\w*|pag\w*|gast\w*|compr\w*|prest\w*|regal\w*|donamos|donaron|done|retir\w*|saqu\w*|invert\w*|factur\w*)\b'
    r'|\bme\s+(?:cobr\w*|descont\w*|debit\w*|quitaron|costo|cargaron)\b',
  );

  static final _looksLikePurchase = RegExp(
    r'\b(?:mercado|super|supermercado|comida|almuerzo|cena|desayuno|restaurante|domicilio|transporte|taxi|uber|didi|gasolina|peaje|parqueadero|factura|recibo|arriendo|alquiler|renta|cuota|servicio|servicios|medicina|farmacia|doctor|consulta|eps|curso|ropa|zapatos|internet|celular|netflix|spotify|suscripcion)\b',
  );

  // Sustantivos y raíces de palabra que indican dinero que ENTRA. Usar
  // raíces (ej. "ingres" en vez de "ingreso") permite reconocer cualquier
  // conjugación: ingreso, ingresé, ingresó, ingresaron, ingresando...
  static const _incomeSignals = [
    'ingres', // ingreso(s), ingresé, ingresó, ingresaron, ingresando
    'sueldo',
    'salari', // salario(s)
    'nomina',
    'quincena',
    'mesada',
    'vent', // venta(s)
    'vend', // vendí, vendimos, vendieron, vendiendo
    'client', // cliente(s)
    'reembols', // reembolso(s), reembolsé, reembolsaron
    'bono',
    'bonific', // bonificación
    'comision',
    'gananc', // ganancia(s)
    'gane',
    'ganamos',
    'ganaron',
    'rendimiento',
    'interes', // interés, intereses
    'dividendo',
    'propina',
    'premio',
    'devolu', // devolución, devoluciones
    'consignac', // consignación, consignaciones
    'pension',
    'acredit', // acreditaron, acreditación
    'liquidac', // liquidación (de nómina)
  ];

  // Sustantivos y raíces de palabra que indican dinero que SALE.
  static const _expenseSignals = [
    'gast', // gasto(s), gasté, gastamos, gastaron, gastando
    'compr', // compra(s), compré, compramos, compraron, comprando
    'pag', // pago(s), pagué, pagamos, pagando
    'cost', // costo(s), costó, costaron
    'cobro',
    'cobros',
    'factur', // factura(s), facturé
    'recibo',
    'recibos',
    'cuota',
    'donac', // donación, donaciones
    'arriendo',
    'alquiler',
    'renta',
    'suscripc', // suscripción, suscripciones
    'mercado',
    'super',
    'restaurante',
    'domicilio',
    'comida',
    'almuerzo',
    'cena',
    'desayuno',
    'transporte',
    'taxi',
    'uber',
    'didi',
    'gasolina',
    'peaje',
    'parqueadero',
    'medicina',
    'farmacia',
    'doctor',
    'consulta',
    'eps',
    'ropa',
    'zapatos',
    'servici', // servicio(s)
    'deud', // deuda(s)
    'multa',
    'impuest', // impuesto(s)
    'internet',
    'celular',
    'netflix',
    'spotify',
    'entretenimiento',
    'cine',
  ];
}
