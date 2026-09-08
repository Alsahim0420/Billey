import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Web OAuth client ID from google-services.json / GoogleService-Info.plist
// (client_type 3). Required so GoogleSignIn can issue a Firebase-compatible
// ID token on Android via Credential Manager; without it, authenticate()
// can fail with GoogleSignInExceptionCode.canceled ("Account reauth failed").
const _googleSignInServerClientId =
    '233183310004-d1t8a2efo220q10rhr7u377rlspr2vah.apps.googleusercontent.com';

// GoogleSignIn.instance is a process-wide singleton that must be
// initialize()d exactly once, so this guard lives at module level rather
// than on AuthService (which is re-created every time the login screen
// is opened).
Future<void>? _googleSignInInitialization;

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
    _googleSignInInitialization ??= googleSignIn.initialize(
      serverClientId: _googleSignInServerClientId,
    );
    await _googleSignInInitialization;
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

  /// The account's current Google profile photo, fetched fresh from Google
  /// (not whatever Firebase Auth's `photoURL` happened to capture at the
  /// last sign-in, which never updates on its own). Returns null if the
  /// account isn't Google-linked, if the user isn't reachable without
  /// interactive sign-in (e.g. revoked access), or has no photo set.
  Future<String?> fetchFreshGooglePhotoUrl() async {
    final isGoogleAccount = _firebaseAuth.currentUser?.providerData
            .any((info) => info.providerId == GoogleAuthProvider.PROVIDER_ID) ??
        false;
    if (!isGoogleAccount) return null;

    try {
      if (kIsWeb) {
        // Firebase Auth's own copy is the only thing available on web
        // without a fresh interactive sign-in — still worth a shot in case
        // it's more current than what we last imported.
        return _firebaseAuth.currentUser?.photoURL;
      }

      final googleSignIn = GoogleSignIn.instance;
      _googleSignInInitialization ??= googleSignIn.initialize(
        serverClientId: _googleSignInServerClientId,
      );
      await _googleSignInInitialization;
      // `attemptLightweightAuthentication()` can itself return null instead
      // of a Future (see its doc comment) — awaiting a null value is valid
      // Dart and simply yields null.
      final account = await googleSignIn.attemptLightweightAuthentication();
      return account?.photoUrl;
    } catch (_) {
      return null;
    }
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
        // Same field a linked partner reads for the couple-sharing avatar
        // pill (see ProfileProvider._syncDisplayNameToFirestore) — kept as
        // a single canonical name instead of a separate 'fullName'.
        'displayName': fullName.trim(),
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
