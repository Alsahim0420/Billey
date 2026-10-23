import 'dart:io';
import 'package:billey/features/speech/config/encrypted_environment_secret_provider.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/services/expense_categorizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encrypted app configuration classifies a fictitious expense via Gemini',
      () async {
    final secrets = EncryptedEnvironmentSecretProvider(
        assetLoader: (path) => File(path).readAsString());
    final service = ExpenseCategorizer(secrets: secrets);
    expect(await service.isConfigured, isTrue);
    final result = await service.categorize(
        TransactionModel(
            id: 'live-test-not-saved',
            title: 'Taxi al aeropuerto',
            amount: 1,
            date: DateTime(2026, 10),
            type: TransactionType.gasto,
            category: TransactionCategory.other),
        CategoryModel.getDefaultCategories(),
        requireAI: true);
    expect(result.categoryId, 'transport');
  },
      skip: Platform.environment['BILLEY_GEMINI_LIVE_TEST'] != '1',
      timeout: const Timeout(Duration(seconds: 30)));
}
