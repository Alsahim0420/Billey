import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyProvider extends ChangeNotifier {
  // Lista de divisas soportadas
  static const List<Currency> supportedCurrencies = [
    Currency('COP', 'Peso colombiano', 'COP\$', 'es_CO'),
    Currency('USD', 'Dólar estadounidense', 'US\$', 'en_US'),
    Currency('EUR', 'Euro', '€', 'es_ES'),
    Currency('MXN', 'Peso mexicano', 'MX\$', 'es_MX'),
    Currency('BRL', 'Real brasileño', 'R\$', 'pt_BR'),
    // Puedes agregar más divisas aquí
  ];

  Currency _selectedCurrency = supportedCurrencies[0]; // COP por defecto

  Currency get selectedCurrency => _selectedCurrency;

  void setCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  String format(double amount) {
    final format = NumberFormat.currency(
      locale: _selectedCurrency.locale,
      symbol: '${_selectedCurrency.symbol} ',
      name: _selectedCurrency.code,
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String locale;

  const Currency(this.code, this.name, this.symbol, this.locale);
}
