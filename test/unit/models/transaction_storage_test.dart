import 'dart:io';
import 'package:billey/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _OldAdapter extends TypeAdapter<TransactionModel> {
  @override
  final typeId = 0;
  @override
  TransactionModel read(BinaryReader reader) => throw UnimplementedError();
  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.description);
  }
}

void main() {
  test(
      'new adapter reads old records and persists custom category and currency',
      () async {
    final dir = await Directory.systemTemp.createTemp('billey-budget-hive-');
    Hive.init(dir.path);
    Hive.registerAdapter(_OldAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionCategoryAdapter());
    addTearDown(() async {
      await Hive.close();
      Hive.resetAdapters();
      await dir.delete(recursive: true);
    });
    var box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(
        'old',
        TransactionModel(
            id: 'old',
            title: 'Original',
            amount: 25000,
            date: DateTime(2026, 10, 22),
            type: TransactionType.gasto,
            category: TransactionCategory.food));
    await box.close();
    Hive.registerAdapter(TransactionModelAdapter(), override: true);
    box = await Hive.openBox<TransactionModel>('transactions');
    expect(box.get('old')!.amount, 25000);
    expect(box.get('old')!.categoryId, isNull);
    expect(box.get('old')!.effectiveCategoryId, 'food');
    await box.put(
        'new',
        TransactionModel(
            id: 'new',
            title: 'Mascotas',
            amount: 30000,
            date: DateTime(2026, 10, 22),
            type: TransactionType.gasto,
            category: TransactionCategory.other,
            categoryId: 'custom_123',
            currencyCode: 'COP'));
    await box.close();
    box = await Hive.openBox<TransactionModel>('transactions');
    expect(box.get('new')!.categoryId, 'custom_123');
    expect(box.get('new')!.currencyCode, 'COP');
    expect(box.get('old')!.amount, 25000);
  });
  test('cloud/map/copy preserve budget category and currency identifiers', () {
    final tx = TransactionModel(
        id: 'new',
        title: 'Mascotas',
        amount: 30000,
        date: DateTime(2026, 10, 22),
        type: TransactionType.gasto,
        category: TransactionCategory.other,
        categoryId: 'custom_123',
        currencyCode: 'COP');
    expect(
        TransactionModel.fromFirestore('new', tx.toFirestore(userId: 'me'))
            .categoryId,
        'custom_123');
    expect(TransactionModel.fromMap(tx.toMap()).currencyCode, 'COP');
    expect(tx.copyWith(sharedWith: ['partner']).categoryId, 'custom_123');
    expect(tx.copyWith().currencyCode, 'COP');
  });
}
