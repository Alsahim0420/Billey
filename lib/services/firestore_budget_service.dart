import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_budget.dart';

class FirestoreBudgetService {
  FirestoreBudgetService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _collection(String owner) =>
      _db.collection('users').doc(owner).collection('categoryBudgets');

  void _checkOwner(String owner) {
    if (_auth.currentUser?.uid != owner) {
      throw StateError('La cuenta cambió. Vuelve a abrir los presupuestos.');
    }
  }

  Stream<List<CategoryBudget>> watch(String owner) =>
      _collection(owner).snapshots().map((snapshot) => snapshot.docs.map((doc) {
            final budget = CategoryBudget.fromMap(doc.data());
            if (budget.id != doc.id) {
              throw const FormatException('ID de presupuesto inválido.');
            }
            return budget;
          }).toList());

  Future<List<CategoryBudget>> readOnce(String owner) async {
    _checkOwner(owner);
    final snapshot =
        await _collection(owner).get(const GetOptions(source: Source.server));
    return snapshot.docs.map((doc) {
      final budget = CategoryBudget.fromMap(doc.data());
      if (budget.id != doc.id) {
        throw const FormatException('ID de presupuesto inválido.');
      }
      return budget;
    }).toList();
  }

  Future<void> save(String owner, CategoryBudget budget) async {
    _checkOwner(owner);
    await _collection(owner).doc(budget.id).set({
      ...budget.toMap(),
      'userId': owner,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String owner, CategoryBudget budget) async {
    _checkOwner(owner);
    await _collection(owner).doc(budget.id).delete();
  }

  /// Read all targets before writing: concurrent edits on another device are
  /// preserved by the transaction's retry instead of being overwritten.
  Future<int> copyMonth(
      String owner, String source, String target, String currency) async {
    _checkOwner(owner);
    final snapshot = await _collection(owner)
        .where('month', isEqualTo: source)
        .where('currency', isEqualTo: currency)
        .get();
    final budgets = snapshot.docs
        .map((d) => CategoryBudget.fromMap(d.data()).forMonth(target))
        .toList();
    if (budgets.isEmpty) return 0;
    if (budgets.length > 400) {
      throw StateError('Demasiados presupuestos para copiar a la vez.');
    }
    _checkOwner(owner);
    return _db.runTransaction((tx) async {
      final missing = <CategoryBudget>[];
      for (final budget in budgets) {
        final doc = await tx.get(_collection(owner).doc(budget.id));
        if (!doc.exists) missing.add(budget);
      }
      for (final budget in missing) {
        tx.set(_collection(owner).doc(budget.id), {
          ...budget.toMap(),
          'userId': owner,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return missing.length;
    });
  }
}
