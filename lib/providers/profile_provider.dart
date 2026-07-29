import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/local_profile_storage.dart';
import '../l10n/app_localizations.dart';

class ProfileProvider extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  String _displayName = LocalProfileStorage.defaultName;
  String _email = LocalProfileStorage.defaultEmail;
  String? _imagePath;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  String get displayName => _displayName;
  String get email => _email;
  String? get imagePath => _imagePath;
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

  bool get hasLocalImage =>
      _imagePath != null && File(_imagePath!).existsSync();

  ProfileProvider() {
    load();
  }

  Future<void> load() async {
    final profile = await LocalProfileStorage.load();
    _displayName = profile.displayName;
    _email = profile.email;
    _imagePath = profile.hasLocalImage ? profile.imagePath : null;
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String displayName,
    required String email,
  }) async {
    final name = displayName.trim();
    final mail = email.trim();

    if (name.length < 2) return false;
    if (!_isValidEmail(mail)) return false;

    await LocalProfileStorage.saveNameAndEmail(
      displayName: name,
      email: mail,
    );

    _displayName = name;
    _email = mail;
    notifyListeners();
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

    _imagePath = await LocalProfileStorage.saveAvatarFromFile(File(picked.path));
    notifyListeners();
    return true;
  }

  Future<void> removeAvatar() async {
    await LocalProfileStorage.clearAvatar();
    _imagePath = null;
    notifyListeners();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
