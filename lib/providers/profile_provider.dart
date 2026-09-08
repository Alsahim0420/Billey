import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';

/// Everything here is sourced from Firebase — no local cache. Display name
/// and email come from Firebase Auth; the avatar photo is uploaded to
/// Firebase Storage (`avatars/{uid}.jpg`) with its URL kept in Firestore
/// `users/{uid}.photoUrl`, so it (like the name) is visible to a linked
/// partner and consistent across devices. A Google-signed-in account's
/// existing Google profile photo is imported into our own Storage once,
/// the first time we notice there's no `photoUrl` of our own yet.
class ProfileProvider extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  String _displayName = '';
  String _email = '';
  String? _avatarUrl;
  bool _isLoaded = false;
  bool _isUploadingAvatar = false;
  String? _avatarError;

  bool get isLoaded => _isLoaded;
  String get displayName => _displayName;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;
  bool get hasAvatar => _avatarUrl != null && _avatarUrl!.isNotEmpty;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get avatarError => _avatarError;

  String get firstName {
    final name = _displayName.trim();
    if (name.isEmpty) return '';
    return name.split(RegExp(r'\s+')).first;
  }

  String defaultUserName(AppLocalizations l10n) =>
      firstName.isEmpty ? l10n.defaultUser : firstName;

  String greetingForHour(int hour, AppLocalizations l10n) {
    final name = defaultUserName(l10n);
    if (hour < 12) return l10n.greetingMorning(name);
    if (hour < 18) return l10n.greetingAfternoon(name);
    return l10n.greetingEvening(name);
  }

  ProfileProvider() {
    load();
  }

  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    _displayName = user?.displayName?.trim() ?? '';
    _email = user?.email?.trim() ?? '';
    _isLoaded = true;
    notifyListeners();

    if (user != null) {
      await _loadProfileDoc(user);
    }
  }

  Future<void> _loadProfileDoc(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      final name = (data?['displayName'] as String?)?.trim();
      if (_displayName.isEmpty && name != null && name.isNotEmpty) {
        _displayName = name;
        notifyListeners();
      }

      final storedUrl = (data?['photoUrl'] as String?)?.trim();
      if (storedUrl != null && storedUrl.isNotEmpty) {
        _avatarUrl = storedUrl;
        notifyListeners();
        return;
      }

      final googlePhotoUrl = user.photoURL;
      if (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty) {
        await _importGooglePhoto(user.uid, googlePhotoUrl);
      }
    } catch (_) {
      // Offline or transient — keep whatever we already had in memory.
    }
  }

  /// Copies a Google account's existing profile photo into our own
  /// Storage, once, so it's ours to serve (not dependent on Google's URL
  /// remaining valid) and so it's stored the same way as any other
  /// user-uploaded avatar.
  Future<void> _importGooglePhoto(String uid, String googlePhotoUrl) async {
    try {
      final response = await http.get(Uri.parse(googlePhotoUrl));
      if (response.statusCode != 200) return;
      final url = await _uploadAvatarBytes(uid, response.bodyBytes);
      _avatarUrl = url;
      notifyListeners();
    } catch (_) {
      // Best effort; the UI just falls back to the initial-letter avatar.
    }
  }

  Future<bool> updateProfile({required String displayName}) async {
    final name = displayName.trim();
    if (name.length < 2) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    await user.updateDisplayName(name);
    await user.reload();

    _displayName = name;
    notifyListeners();
    unawaited(_syncToFirestore(user.uid, {'displayName': name}));
    return true;
  }

  Future<bool> pickAndSaveAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isUploadingAvatar = true;
    _avatarError = null;
    notifyListeners();
    try {
      final url = await _uploadAvatarBytes(
        user.uid,
        await File(picked.path).readAsBytes(),
      );
      _avatarUrl = url;
      return true;
    } catch (error, stackTrace) {
      // Surface the real reason instead of leaving the caller with just
      // `false` — a photo upload can fail for several very different
      // reasons (offline, Storage rules, a bad file) and silently eating
      // the error here previously left the UI stuck spinning forever with
      // no way to tell what went wrong.
      debugPrint('Avatar upload failed: $error\n$stackTrace');
      _avatarError = error.toString();
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<String> _uploadAvatarBytes(String uid, List<int> bytes) async {
    final ref = FirebaseStorage.instance.ref('avatars/$uid.jpg');
    await ref
        .putData(
          Uint8List.fromList(bytes),
          SettableMetadata(contentType: 'image/jpeg'),
        )
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('Avatar upload timed out'),
        );
    final url = await ref.getDownloadURL().timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Fetching avatar URL timed out'),
        );
    await _syncToFirestore(uid, {'photoUrl': url});
    return url;
  }

  Future<void> removeAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseStorage.instance
          .ref('avatars/${user.uid}.jpg')
          .delete()
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Already gone, or offline — either way clear our own record below.
    }
    await _syncToFirestore(user.uid, {'photoUrl': FieldValue.delete()});
    _avatarUrl = null;
    notifyListeners();
  }

  /// Best-effort: failures (e.g. offline) are silently ignored since this
  /// isn't user-facing data for the account owner themselves — it's what a
  /// linked partner reads.
  Future<void> _syncToFirestore(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'uid': uid, ...data}, SetOptions(merge: true));
    } catch (_) {}
  }
}
