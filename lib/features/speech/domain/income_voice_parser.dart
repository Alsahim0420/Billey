import 'expense_voice_parser.dart';

class IncomeVoiceDraft {
  const IncomeVoiceDraft({
    required this.source,
    required this.amount,
    required this.date,
    required this.isSalary,
    required this.requiresRememberedSalary,
    required this.hasSalaryAdjustment,
  });

  final String source;
  final double? amount;
  final DateTime date;
  final bool isSalary;
  final bool requiresRememberedSalary;
  final bool hasSalaryAdjustment;
}

class IncomeVoiceParser {
  const IncomeVoiceParser();

  IncomeVoiceDraft parse(
    String transcript, {
    required DateTime now,
    double? rememberedSalary,
  }) {
    final text = _normalize(transcript);
    final baseDraft = const ExpenseVoiceParser().parse(transcript, now: now);
    final spokenAmount = baseDraft.amount;
    final isSalary = _salaryKeywords.any(text.contains);
    final isReduction = _reductionKeywords.any(text.contains);
    final isIncrease = _increaseKeywords.any(text.contains);
    final hasAdjustment = isSalary && (isReduction || isIncrease);

    double? amount;
    if (isSalary && hasAdjustment) {
      if (rememberedSalary != null && spokenAmount != null) {
        amount = isReduction
            ? rememberedSalary - spokenAmount
            : rememberedSalary + spokenAmount;
        if (amount < 0) amount = 0;
      }
    } else if (isSalary) {
      amount = spokenAmount ?? rememberedSalary;
    } else {
      amount = spokenAmount;
    }

    return IncomeVoiceDraft(
      source: _sourceFor(text, isSalary),
      amount: amount,
      date: baseDraft.date,
      isSalary: isSalary,
      requiresRememberedSalary:
          isSalary && rememberedSalary == null && spokenAmount == null ||
              hasAdjustment && rememberedSalary == null,
      hasSalaryAdjustment: hasAdjustment,
    );
  }

  String _sourceFor(String text, bool isSalary) {
    if (isSalary) return 'Sueldo';
    if (text.contains('cliente')) return 'Pago de cliente';
    if (text.contains('venta')) return 'Venta';
    if (text.contains('reembolso')) return 'Reembolso';
    if (text.contains('bono')) return 'Bono';
    if (text.contains('comision')) return 'Comisión';
    return 'Ingreso';
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

  static const _salaryKeywords = [
    'sueldo',
    'salario',
    'nomina',
  ];

  static const _reductionKeywords = [
    'menos',
    'descontaron',
    'descuento',
    'rebajaron',
    'faltaron',
  ];

  static const _increaseKeywords = [
    ' mas',
    'extra',
    'adicional',
    'aumento',
    'bonificacion',
  ];
}
