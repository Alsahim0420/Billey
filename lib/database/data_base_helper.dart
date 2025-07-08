import 'package:hive/hive.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _boxName = 'transactions';

  DatabaseHelper._init();

  Future<Box<TransactionModel>> get _box async {
    return await Hive.openBox<TransactionModel>(_boxName);
  }

  Future<void> create(TransactionModel transaction) async {
    final box = await _box;
    await box.add(transaction);
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> update(TransactionModel transaction) async {
    final box = await _box;
    // Buscar la transacción por ID
    final index = box.values.toList().indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      await box.putAt(index, transaction);
    }
  }

  Future<void> delete(String id) async {
    final box = await _box;
    // Buscar la transacción por ID y eliminarla
    final index = box.values.toList().indexWhere((t) => t.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  Future<void> close() async {
    final box = await _box;
    await box.close();
  }
}
