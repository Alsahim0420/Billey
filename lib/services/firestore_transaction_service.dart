import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction.dart';

class FirestoreTransactionService {
  FirestoreTransactionService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference<Map<String, dynamic>> _transactionsFor(User user) =>
      _firestore.collection('users').doc(user.uid).collection('transactions');

  Future<List<TransactionModel>> readAll() async {
    final user = currentUser;
    if (user == null) return [];
    final snapshot =
        await _transactionsFor(user).orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(
            doc.id, {...doc.data(), 'userId': user.uid}))
        .toList();
  }

  /// Transactions a linked partner has explicitly shared with the current
  /// user (i.e. `sharedWith` on the partner's own transaction contains our
  /// uid). Requires [FirestoreTransactionService]'s own security rules to
  /// permit the cross-account read.
  Future<List<TransactionModel>> readSharedByPartner(String partnerUid) async {
    final user = currentUser;
    if (user == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(partnerUid)
        .collection('transactions')
        .where('sharedWith', arrayContains: user.uid)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(
            doc.id, {...doc.data(), 'userId': partnerUid}))
        .toList();
  }

  Future<void> create(TransactionModel transaction) async {
    final user = _requireUser();
    final id = _requireTransactionId(transaction);
    await _transactionsFor(user).doc(id).set({
      ...transaction.toFirestore(userId: user.uid),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Uses the existing collection and security rules. A lost acknowledgment
  /// may retry, but must never overwrite an existing expense or its edits.
  Future<void> importApplePay(
      TransactionModel transaction, String owner) async {
    final user = _requireUser();
    if (user.uid != owner) {
      throw StateError(
          'La cuenta cambió. Reintenta al volver a la cuenta de recepción.');
    }
    final ref = _transactionsFor(user).doc(_requireTransactionId(transaction));
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) return;
      tx.set(ref, {
        ...transaction.toFirestore(userId: owner),
        'source': 'apple_pay_shortcuts',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> update(TransactionModel transaction) async {
    final user = _requireUser();
    final id = _requireTransactionId(transaction);
    await _transactionsFor(user).doc(id).update({
      ...transaction.toFirestore(userId: user.uid),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update category fields only, with an atomic check against concurrent edits.
  Future<bool> categorizeIfUnchanged(
      TransactionModel before, TransactionModel after, String owner) async {
    final user = _requireUser();
    if (user.uid != owner) throw StateError('La cuenta cambió.');
    if (before.type != TransactionType.gasto ||
        before.effectiveCategoryId != 'other' ||
        after.effectiveCategoryId == 'other') {
      return false;
    }
    final ref = _transactionsFor(user).doc(_requireTransactionId(before));
    return _firestore.runTransaction((tx) async {
      if (_requireUser().uid != owner) throw StateError('La cuenta cambió.');
      final snapshot = await tx.get(ref);
      final data = snapshot.data();
      if (data == null ||
          data['type'] != 'gasto' ||
          (data['userId'] != null && data['userId'] != owner) ||
          data['title'] != before.title ||
          (data['category'] ?? 'other') != before.category.name ||
          data['categoryId'] != before.categoryId) {
        return false;
      }
      tx.update(ref, {
        'category': after.category.name,
        'categoryId': after.effectiveCategoryId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  Future<void> delete(String transactionId) async {
    final user = _requireUser();
    if (transactionId.trim().isEmpty) {
      throw ArgumentError.value(transactionId, 'transactionId');
    }
    await _transactionsFor(user).doc(transactionId).delete();
  }

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para gestionar transacciones.');
    }
    return user;
  }

  String _requireTransactionId(TransactionModel transaction) {
    final id = transaction.id?.trim();
    if (id == null || id.isEmpty) {
      throw ArgumentError('La transacción requiere un identificador.');
    }
    return id;
  }
}
