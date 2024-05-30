import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const dateType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE transactions ( 
  id $idType, 
  title $textType,
  amount $doubleType,
  date $dateType,
  type $textType
  )
''');
  }

  Future<void> create(TransactionModel transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final db = await instance.database;

    final result = await db.query('transactions');

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> update(TransactionModel transaction) async {
    final db = await instance.database;

    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await instance.database;

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
