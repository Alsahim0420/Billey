import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserProfile {
  final String displayName;
  final String email;
  final String? imagePath;

  const LocalUserProfile({
    required this.displayName,
    required this.email,
    this.imagePath,
  });

  bool get hasLocalImage =>
      imagePath != null && File(imagePath!).existsSync();

  String get firstName {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Usuario' : parts.first;
  }
}

class LocalProfileStorage {
  static const _nameKey = 'profile_display_name';
  static const _emailKey = 'profile_email';
  static const _imagePathKey = 'profile_image_path';
  static const _avatarFileName = 'profile_avatar.jpg';

  static const String defaultName = '';
  static const String defaultEmail = '';

  /// Indica si el usuario ya personalizó su perfil (nombre o email).
  static Future<bool> hasCustomProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final hasName = prefs.containsKey(_nameKey);
    final hasEmail = prefs.containsKey(_emailKey);
    if (!hasName && !hasEmail) return false;
    final name = (prefs.getString(_nameKey) ?? '').trim();
    final email = (prefs.getString(_emailKey) ?? '').trim();
    return name.isNotEmpty && email.isNotEmpty;
  }

  static Future<LocalUserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_imagePathKey);

    return LocalUserProfile(
      displayName: prefs.getString(_nameKey) ?? defaultName,
      email: prefs.getString(_emailKey) ?? defaultEmail,
      imagePath: imagePath,
    );
  }

  static Future<void> saveNameAndEmail({
    required String displayName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, displayName.trim());
    await prefs.setString(_emailKey, email.trim());
  }

  static Future<String> saveAvatarFromFile(File source) async {
    final directory = await getApplicationDocumentsDirectory();
    final destination = File('${directory.path}/$_avatarFileName');
    await source.copy(destination.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imagePathKey, destination.path);
    return destination.path;
  }

  static Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPath = prefs.getString(_imagePathKey);
    if (currentPath != null) {
      final file = File(currentPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove(_imagePathKey);
  }
}
