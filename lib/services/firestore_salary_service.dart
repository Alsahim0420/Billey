import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreSalaryService {
  FirestoreSalaryService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<double?> load() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final value = snapshot.data()?['salaryAmount'];
    return value is num ? value.toDouble() : null;
  }

  Future<void> save(double salary) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión para guardar tu sueldo.');
    }
    await _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'salaryAmount': salary,
        'salaryUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
