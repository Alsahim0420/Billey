import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/savings_goal.dart';

class FirestoreGoalsService {
  FirestoreGoalsService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference<Map<String, dynamic>> _goalsFor(User user) =>
      _firestore.collection('users').doc(user.uid).collection('goals');

  Future<List<SavingsGoal>> readAll() async {
    final user = currentUser;
    if (user == null) return [];
    final snapshot =
        await _goalsFor(user).orderBy('createdAt', descending: false).get();
    return snapshot.docs
        .map((doc) => SavingsGoal.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Goals a linked partner has explicitly shared with the current user
  /// (i.e. `sharedWith` on the partner's own goal contains our uid).
  /// Requires matching Firestore security rules to permit the cross-account
  /// read.
  Future<List<SavingsGoal>> readSharedByPartner(String partnerUid) async {
    final user = currentUser;
    if (user == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(partnerUid)
        .collection('goals')
        .where('sharedWith', arrayContains: user.uid)
        .get();
    return snapshot.docs
        .map((doc) => SavingsGoal.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> create(SavingsGoal goal) async {
    final user = _requireUser();
    await _goalsFor(user).doc(goal.id).set({
      ...goal.toFirestore(userId: user.uid),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(SavingsGoal goal) async {
    final user = _requireUser();
    await _goalsFor(user).doc(goal.id).update({
      ...goal.toFirestore(userId: user.uid),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String goalId) async {
    final user = _requireUser();
    if (goalId.trim().isEmpty) {
      throw ArgumentError.value(goalId, 'goalId');
    }
    await _goalsFor(user).doc(goalId).delete();
  }

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para gestionar metas.');
    }
    return user;
  }
}
