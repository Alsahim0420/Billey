import 'package:billey/providers/currency_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats and parses Colombian currency with thousand separators', () {
    final provider = CurrencyProvider();

    expect(provider.format(1250000), r'$ 1.250.000');
    expect(provider.formatValue(1250000), '1.250.000');
    expect(provider.parseValue('1.250.000'), 1250000);
  });

  test('uses the selected currency locale and decimals', () {
    final provider = CurrencyProvider()
      ..setCurrency(CurrencyProvider.supportedCurrencies[1]);

    expect(provider.format(1250.5), r'$ 1,250.50');
    expect(provider.parseValue('1,250.50'), 1250.5);
  });

  test('adds signs without duplicating the currency symbol', () {
    final provider = CurrencyProvider();

    expect(provider.formatWithSign(50000, isIncome: true), r'+$ 50.000');
    expect(provider.formatWithSign(50000, isIncome: false), r'-$ 50.000');
  });
}
