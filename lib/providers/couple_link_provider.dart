import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Manages the "linked partner" relationship used for shared finances:
/// generating/redeeming the rotating 6-digit pairing code (via Cloud
/// Functions) and exposing the active link (if any) so the rest of the app
/// can show/filter shared transactions.
class CoupleLinkProvider extends ChangeNotifier {
  CoupleLinkProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  static const codeTtl = Duration(minutes: 5);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _partnerSub;
  Timer? _codeRefreshTimer;
  Timer? _tickTimer;

  bool _isLoaded = false;
  String? _coupleId;
  String? _partnerUid;
  String? _partnerDisplayName;
  String? _partnerPhotoUrl;

  String? _myCode;
  DateTime? _codeExpiresAt;
  bool _isGeneratingCode = false;
  bool _isRedeeming = false;
  String? _error;

  bool get isLoaded => _isLoaded;
  bool get isLinked => _coupleId != null;
  String? get partnerUid => _partnerUid;
  String? get partnerDisplayName => _partnerDisplayName;
  String? get partnerPhotoUrl => _partnerPhotoUrl;
  String? get myCode => _myCode;
  bool get isGeneratingCode => _isGeneratingCode;
  bool get isRedeeming => _isRedeeming;
  String? get error => _error;

  /// UIDs a newly-created transaction should be shared with by default if
  /// the user opts in — just the partner's, or empty if not linked.
  List<String> get shareableUids => _partnerUid != null ? [_partnerUid!] : const [];

  Duration get codeRemaining {
    final expiresAt = _codeExpiresAt;
    if (expiresAt == null) return Duration.zero;
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void initialize() {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    // A previous account's listeners must not keep running: once signed
    // out, their next snapshot event has no authenticated uid and
    // Firestore's security rules reject it, throwing an unhandled
    // permission-denied error.
    _userSub?.cancel();
    _userSub = null;
    _partnerSub?.cancel();
    _partnerSub = null;
    stopGeneratingCode();
    _coupleId = null;
    _partnerUid = null;
    _partnerDisplayName = null;
    _myCode = null;
    _codeExpiresAt = null;

    final uid = user?.uid;
    if (uid == null) {
      _isLoaded = true;
      notifyListeners();
      return;
    }

    _userSub = _firestore.collection('users').doc(uid).snapshots().listen(
      (snapshot) => _onUserDocChanged(snapshot),
      onError: (_) {
        _isLoaded = true;
        notifyListeners();
      },
    );
  }

  void _onUserDocChanged(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final coupleId = snapshot.data()?['coupleId'] as String?;
    if (coupleId != _coupleId) {
      _coupleId = coupleId;
      _watchPartner();
    }
    _isLoaded = true;
    notifyListeners();
  }

  void _watchPartner() {
    _partnerSub?.cancel();
    _partnerSub = null;
    _partnerUid = null;
    _partnerDisplayName = null;
    _partnerPhotoUrl = null;

    final coupleId = _coupleId;
    final myUid = _auth.currentUser?.uid;
    if (coupleId == null || myUid == null) {
      notifyListeners();
      return;
    }

    _firestore.collection('couples').doc(coupleId).get().then((coupleSnap) {
      final members =
          (coupleSnap.data()?['memberUids'] as List<dynamic>?)?.cast<String>() ??
              const [];
      final partnerUid = members.firstWhere(
        (id) => id != myUid,
        orElse: () => '',
      );
      if (partnerUid.isEmpty) return;
      _partnerUid = partnerUid;
      _partnerSub = _firestore
          .collection('users')
          .doc(partnerUid)
          .snapshots()
          .listen(
        (snapshot) {
          _partnerDisplayName = snapshot.data()?['displayName'] as String?;
          _partnerPhotoUrl = snapshot.data()?['photoUrl'] as String?;
          notifyListeners();
        },
        // e.g. signed out or unlinked mid-flight: nothing to surface here,
        // the auth/user-doc listeners already reset state in that case.
        onError: (_) {},
      );
      notifyListeners();
    }).catchError((_) {
      // Same as above: a stale read racing a sign-out/unlink is expected.
    });
  }

  /// Requests a fresh 6-digit code and keeps re-requesting a new one every
  /// [codeTtl] while the pairing screen stays open, so the code visibly
  /// "rotates" for as long as the user is looking at it. Call
  /// [stopGeneratingCode] when leaving the screen.
  Future<void> startGeneratingCode() async {
    await _requestNewCode();
    _codeRefreshTimer?.cancel();
    _codeRefreshTimer = Timer.periodic(codeTtl, (_) => _requestNewCode());
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void stopGeneratingCode() {
    _codeRefreshTimer?.cancel();
    _codeRefreshTimer = null;
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  Future<void> _requestNewCode() async {
    _isGeneratingCode = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _functions.httpsCallable('generatePairingCode').call();
      final data = result.data as Map<Object?, Object?>;
      _myCode = data['code'] as String?;
      final expiresAtMillis = data['expiresAtMillis'] as int?;
      _codeExpiresAt = expiresAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresAtMillis)
          : null;
    } on FirebaseFunctionsException catch (e) {
      _error = e.message ?? 'No se pudo generar el código.';
    } finally {
      _isGeneratingCode = false;
      notifyListeners();
    }
  }

  /// Redeems a partner's code. Returns null on success, or an error message.
  Future<String?> redeemCode(String code) async {
    _isRedeeming = true;
    _error = null;
    notifyListeners();
    try {
      await _functions.httpsCallable('redeemPairingCode').call({'code': code});
      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message ?? 'No se pudo vincular con ese código.';
    } finally {
      _isRedeeming = false;
      notifyListeners();
    }
  }

  Future<String?> unlink() async {
    try {
      await _functions.httpsCallable('unlinkCouple').call();
      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message ?? 'No se pudo desvincular.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _partnerSub?.cancel();
    _codeRefreshTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }
}
