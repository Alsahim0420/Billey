import 'dart:convert';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/database/data_base_helper.dart';
import 'package:billey/services/expense_categorizer.dart';
import 'package:billey/features/speech/config/secret_provider.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Storage extends Fake implements DatabaseHelper {
  final rows = <TransactionModel>[];
  @override
  Future<void> create(TransactionModel transaction) async {
    rows.add(transaction);
  }

  @override
  Future<List<TransactionModel>> readAllTransactions() async => rows.toList();
}

class _Secrets implements SecretProvider {
  _Secrets([this.key = 'test-key']);
  final String key;
  @override
  Future<void> initialize() async {}
  @override
  String? getOptional(String key) => key == 'GEMINI_API_KEY' ? this.key : null;
  @override
  String getRequired(String key) => getOptional(key)!;
}

TransactionModel tx(String title) => TransactionModel(
    id: 'stable',
    title: title,
    amount: 12000,
    date: DateTime(2026, 10),
    type: TransactionType.gasto,
    category: TransactionCategory.other,
    currencyCode: 'COP',
    description: 'private card',
    ownerId: 'me',
    sharedWith: ['partner']);
http.Response answer(String id) => http.Response(
    jsonEncode({
      'candidates': [
        {
          'finishReason': 'STOP',
          'content': {
            'parts': [
              {
                'text': jsonEncode({'categoryId': id})
              }
            ]
          }
        }
      ]
    }),
    200);
void main() {
  test(
      'bounded structured classification uses actual IDs, minimal data and cached calls',
      () async {
    var calls = 0;
    final service = ExpenseCategorizer(
        secrets: _Secrets(),
        client: MockClient((request) async {
          calls++;
          final body = jsonDecode(request.body) as Map;
          expect(request.url.query, isEmpty);
          final input =
              jsonDecode(body['contents'][0]['parts'][0]['text'] as String)
                  as Map;
          expect(input['title'], 'Uber');
          expect(input['categories'], [
            for (final c
                in (CategoryModel.getDefaultCategories()
                    .where((c) => c.isActive && c.id != 'other')
                    .toList()
                  ..sort((a, b) => a.id.compareTo(b.id))))
              {'id': c.id, 'name': c.name}
          ]);
          expect(body['generationConfig']['responseSchema']['required'],
              ['categoryId']);
          expect(
              body['generationConfig']['responseSchema']['properties']
                  ['categoryId'],
              {'type': 'STRING'});

          expect(request.headers['x-goog-api-key'], 'test-key');
          expect(request.body, isNot(contains('private card')));
          expect(request.body, isNot(contains('partner')));
          expect(request.body, isNot(contains('12000')));
          expect((body['generationConfig'] as Map)['maxOutputTokens'], 64);
          expect(request.url.path, contains('gemini-3.5-flash-lite'));
          expect(body['generationConfig']['thinkingConfig'],
              {'thinkingLevel': 'MINIMAL'});
          expect(request.body, isNot(contains('"other"')));
          return answer('transport');
        }));
    final result = await service.categorize(
        tx('Uber'), CategoryModel.getDefaultCategories());
    expect(result.categoryId, 'transport');
    expect(result.id, 'stable');
    expect(result.sharedWith, ['partner']);
    expect(result.description, 'private card');
    await service.categorize(tx('Uber'), CategoryModel.getDefaultCategories());
    expect(calls, 1);
    service.clear();
    await service.categorize(tx('Uber'), CategoryModel.getDefaultCategories());
    expect(calls, 2);
  });
  test('unknown or invented categories require review instead of Other',
      () async {
    for (final id in ['', 'invented', 'other']) {
      final service = ExpenseCategorizer(
          secrets: _Secrets(), client: MockClient((_) async => answer(id)));
      await expectLater(
          service.categorize(tx('XYZ'), CategoryModel.getDefaultCategories()),
          throwsA(isA<CategoryReviewRequired>()));
    }
  });
  test(
      '429 cools down, uses local rules, and never drops unknown expenses silently',
      () async {
    var calls = 0;
    final service = ExpenseCategorizer(
        secrets: _Secrets(),
        client: MockClient((_) async {
          calls++;
          return http.Response('quota', 429);
        }));
    expect(
        (await service.categorize(
                tx('taxi'), CategoryModel.getDefaultCategories()))
            .categoryId,
        'transport');
    await expectLater(
        service.categorize(tx('XYZ'), CategoryModel.getDefaultCategories()),
        throwsA(isA<CategoryReviewRequired>()));
    expect(calls, 1);
  });
  test(
      'save pipeline blocks unknown, accepts manual selection and categorizes Apple Pay',
      () async {
    final storage = _Storage();
    final provider = TransactionProvider.withDb(storage)
      ..categorizer = ExpenseCategorizer(secrets: _Secrets(''))
      ..categoryCatalog = CategoryModel.getDefaultCategories;
    await expectLater(provider.addTransaction(tx('XYZ')),
        throwsA(isA<CategoryReviewRequired>()));
    expect(storage.rows, isEmpty);
    final selected = TransactionModel(
        id: 'manual',
        title: 'XYZ',
        amount: 100,
        date: DateTime(2026, 10),
        type: TransactionType.gasto,
        category: TransactionCategory.health,
        categoryId: 'health');
    await provider.addTransaction(selected, categorySelectedManually: true);
    expect(storage.rows.single.categoryId, 'health');
    await provider.importApplePay(tx('taxi'), 'me');
    expect(storage.rows.last.categoryId, 'transport');
    expect(storage.rows.last.id, 'stable');
    provider.dispose();
  });
  test('migration requires AI even when local rules or cache can classify',
      () async {
    final service = ExpenseCategorizer(
        secrets: _Secrets(),
        client: MockClient((_) async => http.Response('quota', 429)));
    final categories = CategoryModel.getDefaultCategories();
    expect((await service.categorize(tx('taxi'), categories)).categoryId,
        'transport');
    await expectLater(
        service.categorize(tx('taxi'), categories, requireAI: true),
        throwsA(isA<CategoryReviewRequired>()));
  });
  test('missing key supports local categorization without HTTP', () async {
    final service = ExpenseCategorizer(
        secrets: _Secrets(''),
        client: MockClient((_) async => throw StateError('No call expected')));
    expect(
        (await service.categorize(
                tx('taxi'), CategoryModel.getDefaultCategories()))
            .categoryId,
        'transport');
  });
}
