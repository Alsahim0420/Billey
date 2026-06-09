import '../models/transaction.dart';

class VoiceParseResult {
  final String? title;
  final double? amount;
  final TransactionCategory? category;
  final TransactionType type;

  const VoiceParseResult({
    this.title,
    this.amount,
    this.category,
    this.type = TransactionType.gasto,
  });

  bool get canSaveExpense =>
      type == TransactionType.gasto &&
      amount != null &&
      amount! > 0 &&
      (title != null && title!.trim().length >= 3);
}

/// Interpreta frases en español para crear un gasto.
/// Ej: "Gasté 25 mil en comida del supermercado"
class VoiceExpenseParser {
  static const _categoryKeywords = <TransactionCategory, List<String>>{
    TransactionCategory.food: [
      'comida',
      'restaurante',
      'almuerzo',
      'cena',
      'desayuno',
      'supermercado',
      'mercado',
      'café',
      'cafe',
      'panaderia',
      'panadería',
      'domicilio',
      'rappi',
    ],
    TransactionCategory.transport: [
      'transporte',
      'taxi',
      'uber',
      'didi',
      'gasolina',
      'combustible',
      'metro',
      'bus',
      'pasaje',
      'parqueadero',
      'estacionamiento',
    ],
    TransactionCategory.entertainment: [
      'entretenimiento',
      'cine',
      'pelicula',
      'película',
      'netflix',
      'spotify',
      'fiesta',
      'bar',
    ],
    TransactionCategory.health: [
      'salud',
      'medico',
      'médico',
      'farmacia',
      'medicina',
      'hospital',
      'consulta',
    ],
    TransactionCategory.education: [
      'educacion',
      'educación',
      'curso',
      'universidad',
      'colegio',
      'libro',
      'matricula',
      'matrícula',
    ],
    TransactionCategory.other: [
      'otros',
      'compra',
      'pago',
      'servicio',
    ],
  };

  static const _incomeKeywords = [
    'ingreso',
    'cobre',
    'cobré',
    'recibi',
    'recibí',
    'salario',
    'sueldo',
    'deposito',
    'depósito',
  ];

  static VoiceParseResult parse(String raw) {
    final text = raw.toLowerCase().trim();
    if (text.isEmpty) return const VoiceParseResult();

    final type = _incomeKeywords.any(text.contains)
        ? TransactionType.ingreso
        : TransactionType.gasto;

    final amount = _extractAmount(text);
    final category = _extractCategory(text);
    final title = _extractTitle(text, amount, category);

    return VoiceParseResult(
      title: title,
      amount: amount,
      category: category,
      type: type,
    );
  }

  static double? _extractAmount(String text) {
    final milMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:mil|k)\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (milMatch != null) {
      final base = _parseNumber(milMatch.group(1)!);
      if (base != null) return base * 1000;
    }

    final patterns = [
      RegExp(r'\b(\d{4,})\b'),
      RegExp(r'\b(\d+(?:[.,]\d{1,2}))\b'),
      RegExp(
        r'(?:gast[eé]|pagu[eé]|son|de|por)\s*(\d+(?:[.,]\d{1,2})?)',
        caseSensitive: false,
      ),
      RegExp(r'\b(\d{1,3})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = _parseNumber(match.group(1)!);
        if (value != null && value > 0) return value;
      }
    }

    return null;
  }

  static double? _parseNumber(String raw) {
    var normalized = raw.trim();
    if (normalized.contains('.') && normalized.contains(',')) {
      if (normalized.lastIndexOf(',') > normalized.lastIndexOf('.')) {
        normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = normalized.replaceAll(',', '');
      }
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  static TransactionCategory? _extractCategory(String text) {
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) return entry.key;
      }
    }
    return null;
  }

  static String? _extractTitle(
    String text,
    double? amount,
    TransactionCategory? category,
  ) {
    var working = text;

    if (amount != null) {
      working = working.replaceAll(
        RegExp(
          r'(\d{1,3}(?:\.\d{3})*(?:,\d{1,2})?|\d+(?:[.,]\d+)?)\s*(?:mil|k)?',
          caseSensitive: false,
        ),
        ' ',
      );
    }

    for (final keywords in _categoryKeywords.values) {
      for (final keyword in keywords) {
        working = working.replaceAll(keyword, ' ');
      }
    }

    const noise = [
      'gasté',
      'gaste',
      'pagué',
      'pague',
      'pago',
      'por',
      'en',
      'de',
      'el',
      'la',
      'los',
      'las',
      'del',
      'al',
      'un',
      'una',
      'pesos',
      'peso',
      'cop',
      'usd',
      'mil',
    ];

    for (final word in noise) {
      working = working.replaceAll(RegExp('\\b$word\\b'), ' ');
    }

    working = working.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (working.length >= 3) {
      return _capitalize(working);
    }

    if (category != null) {
      return _defaultTitleForCategory(category);
    }

    return amount != null ? 'Gasto por voz' : null;
  }

  static String _defaultTitleForCategory(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Comida';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.entertainment:
        return 'Entretenimiento';
      case TransactionCategory.health:
        return 'Salud';
      case TransactionCategory.education:
        return 'Educación';
      case TransactionCategory.other:
        return 'Gasto';
    }
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
