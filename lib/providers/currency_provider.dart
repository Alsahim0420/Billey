import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyProvider extends ChangeNotifier {
  // Lista de divisas soportadas
  static const List<Currency> supportedCurrencies = [
    Currency('COP', 'Peso colombiano', r'$', 'es_CO'),
    Currency('USD', 'Dólar estadounidense', r'$', 'en_US'),
    Currency('EUR', 'Euro', '€', 'es_ES'),
    Currency('MXN', 'Peso mexicano', r'$', 'es_MX'),
    Currency('BRL', 'Real brasileño', r'R$', 'pt_BR'),
    // Puedes agregar más divisas aquí
  ];

  Currency _selectedCurrency = supportedCurrencies[0]; // COP por defecto

  Currency get selectedCurrency => _selectedCurrency;

  void setCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  bool get usesDecimals => _selectedCurrency.code != 'COP';

  String format(double amount) {
    return '${_selectedCurrency.symbol} ${formatValue(amount)}';
  }

  /// Monto sin símbolo (ej. 5.300.000). No usa [NumberFormat.currency] para
  /// evitar que el locale inserte el código ISO (p. ej. COP).
  String formatValue(double amount) {
    final value = usesDecimals ? amount : amount.roundToDouble();
    final locale = _selectedCurrency.locale;
    if (!usesDecimals) {
      return NumberFormat('#,##0', locale).format(value);
    }
    return NumberFormat('#,##0.00', locale).format(value);
  }

  String formatWithSign(double amount, {required bool isIncome}) {
    if (amount == 0) return format(0);
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount.abs())}';
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String locale;

  const Currency(this.code, this.name, this.symbol, this.locale);
}
