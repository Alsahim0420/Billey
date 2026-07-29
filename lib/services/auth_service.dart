import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  FirebaseFirestore get firestore => _firestore;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await userCredential.user?.updateDisplayName(fullName.trim());

    await _saveUserProfile(
      userCredential.user!,
      fullName: fullName.trim(),
      email: email.trim(),
      birthDate: birthDate,
      provider: 'email',
    );
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      final userCredential = await _firebaseAuth.signInWithPopup(provider);
      await _saveUserProfile(
        userCredential.user!,
        fullName: userCredential.user?.displayName ?? '',
        email: userCredential.user?.email ?? '',
        birthDate: null,
        provider: 'google',
      );
      return;
    }

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final googleUser = await googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await _saveUserProfile(
      userCredential.user!,
      fullName: userCredential.user?.displayName ?? '',
      email: userCredential.user?.email ?? '',
      birthDate: null,
      provider: 'google',
    );
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  Future<void> _saveUserProfile(
    User user, {
    required String fullName,
    required String email,
    DateTime? birthDate,
    required String provider,
  }) async {
    await _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'birthDate': birthDate?.toIso8601String(),
        'provider': provider,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String? validateSignUpData({
    required String fullName,
    required String email,
    required String password,
    required DateTime? birthDate,
  }) {
    final normalizedName = fullName.trim();
    if (normalizedName.length < 2) {
      return 'Ingresa tu nombre completo';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Ingresa un correo válido';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    if (birthDate == null) {
      return 'Selecciona tu fecha de nacimiento';
    }

    final minimumAgeDate =
        DateTime.now().subtract(const Duration(days: 365 * 13));
    if (birthDate.isAfter(minimumAgeDate)) {
      return 'Debes tener al menos 13 años';
    }

    return null;
  }
}
