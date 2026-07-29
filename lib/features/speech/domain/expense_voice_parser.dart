class ExpenseVoiceDraft {
  const ExpenseVoiceDraft({
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
  });

  final String title;
  final double? amount;
  final String categoryId;
  final DateTime date;
}

class ExpenseVoiceParser {
  const ExpenseVoiceParser();

  ExpenseVoiceDraft parse(
    String transcript, {
    required DateTime now,
    Map<String, String> customCategories = const {},
  }) {
    final text = _normalize(transcript);
    final categoryId = _categoryFor(text, customCategories);
    return ExpenseVoiceDraft(
      title: _titleFor(text, categoryId),
      amount: _extractAmount(text),
      categoryId: categoryId,
      date: _extractDate(text, now),
    );
  }

  String _categoryFor(String text, Map<String, String> customCategories) {
    for (final category in customCategories.entries) {
      if (text.contains(_normalize(category.value))) return category.key;
    }
    for (final category in _categoryKeywords.entries) {
      if (category.value.any(text.contains)) return category.key;
    }
    return 'other';
  }

  String _titleFor(String text, String categoryId) {
    for (final title in _preferredTitles.entries) {
      if (text.contains(title.key)) return title.value;
    }
    return const {
          'food': 'Comida',
          'transport': 'Transporte',
          'entertainment': 'Entretenimiento',
          'health': 'Salud',
          'education': 'Educación',
          'other': 'Gasto',
        }[categoryId] ??
        'Gasto';
  }

  double? _extractAmount(String text) {
    if (RegExp(r'\bmedio millon\b').hasMatch(text)) {
      return 500000;
    }

    final numeric = RegExp(
      r'(?:\$|cop\s*)?(\d{1,3}(?:[.,]\d{3})+|\d+)(?:\s*(millon(?:es)?|mil)\b)?',
    ).firstMatch(text);
    if (numeric != null) {
      var value =
          double.tryParse(numeric.group(1)!.replaceAll(RegExp(r'[.,]'), ''));
      final scale = numeric.group(2);
      if (value != null && scale == 'mil' && value < 1000) value *= 1000;
      if (value != null && (scale?.startsWith('millon') ?? false)) {
        value *= 1000000;
        if (RegExp(r'\bmillon(?:es)? y medio\b').hasMatch(text)) {
          value += 500000;
        }
      }
      return value;
    }

    final tokens = text.split(' ');
    var best = 0;
    for (var start = 0; start < tokens.length; start++) {
      if (!_numberWords.containsKey(tokens[start]) &&
          tokens[start] != 'mil' &&
          !tokens[start].startsWith('millon')) {
        continue;
      }
      var total = 0;
      var current = 0;
      for (var index = start; index < tokens.length; index++) {
        final token = tokens[index];
        if (token == 'y') continue;
        final value = _numberWords[token];
        if (value != null) {
          current += value;
        } else if (token == 'mil') {
          total += (current == 0 ? 1 : current) * 1000;
          current = 0;
        } else if (token.startsWith('millon')) {
          total += (current == 0 ? 1 : current) * 1000000;
          current = 0;
        } else {
          break;
        }
        if (total + current > best) best = total + current;
      }
    }
    if (best == 0) return null;
    if (best >= 1000000 &&
        RegExp(r'\bmillon(?:es)? y medio\b').hasMatch(text)) {
      best += 500000;
    }
    return best.toDouble();
  }

  DateTime _extractDate(String text, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (text.contains('anteayer')) {
      return today.subtract(const Duration(days: 2));
    }
    if (text.contains('ayer')) return today.subtract(const Duration(days: 1));
    return today;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9\$.,ñ]+'), ' ')
      .trim();

  static const _preferredTitles = <String, String>{
    'supermercado': 'Mercado',
    'mercado': 'Mercado',
    'restaurante': 'Restaurante',
    'almuerzo': 'Almuerzo',
    'desayuno': 'Desayuno',
    'cena': 'Cena',
    'comida': 'Comida',
    'helados': 'Helados',
    'helado': 'Helado',
    'gasolina': 'Gasolina',
    'uber': 'Uber',
    'taxi': 'Taxi',
    'parqueadero': 'Parqueadero',
    'farmacia': 'Farmacia',
    'medico': 'Médico',
    'cine': 'Cine',
    'netflix': 'Netflix',
    'universidad': 'Universidad',
    'curso': 'Curso',
  };

  static const _categoryKeywords = <String, List<String>>{
    'food': [
      'comida',
      'restaurante',
      'almuerzo',
      'desayuno',
      'cena',
      'mercado',
      'supermercado',
      'cafe',
      'hamburguesa',
      'pizza',
      'helado',
      'helados',
    ],
    'transport': [
      'transporte',
      'taxi',
      'uber',
      'bus',
      'gasolina',
      'parqueadero',
      'peaje',
    ],
    'entertainment': [
      'cine',
      'netflix',
      'concierto',
      'fiesta',
      'juego',
      'entretenimiento',
    ],
    'health': ['salud', 'farmacia', 'medico', 'hospital', 'odontologo'],
    'education': ['educacion', 'curso', 'libro', 'universidad', 'colegio'],
  };

  static const _numberWords = <String, int>{
    'un': 1,
    'uno': 1,
    'una': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
    'once': 11,
    'doce': 12,
    'trece': 13,
    'catorce': 14,
    'quince': 15,
    'veinte': 20,
    'treinta': 30,
    'cuarenta': 40,
    'cincuenta': 50,
    'sesenta': 60,
    'setenta': 70,
    'ochenta': 80,
    'noventa': 90,
    'cien': 100,
    'ciento': 100,
    'doscientos': 200,
    'trescientos': 300,
    'cuatrocientos': 400,
    'quinientos': 500,
    'seiscientos': 600,
    'setecientos': 700,
    'ochocientos': 800,
    'novecientos': 900,
  };
}
