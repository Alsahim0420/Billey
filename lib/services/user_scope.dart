import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Namespaces local-storage keys/box names by the signed-in Firebase user,
/// so switching accounts on the same device never shows one user's local
/// data (profile, categories, goals, reminders, budget config) to another.
///
/// Local storage (SharedPreferences, Hive) has no concept of "the current
/// user" on its own — unlike Firestore paths, which are already safely
/// scoped under `users/{uid}/...`. Every local key/box name must be
/// suffixed with the uid explicitly, or it leaks across accounts.
class UserScope {
  const UserScope._();

  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  /// Suffixes [base] with the current uid, e.g. `profile_display_name` ->
  /// `profile_display_name__AbC123`. Falls back to [base] itself when
  /// signed out (that data shouldn't normally be read/written then).
  static String key(String base) {
    final uid = currentUid;
    return uid == null ? base : '${base}__$uid';
  }

  /// One-time migration for a String-valued SharedPreferences entry: if
  /// the old global [base] key has data and the new scoped key doesn't
  /// yet, copy it over for the currently signed-in user (the common
  /// single-user-device case), then delete the global key so it can never
  /// be copied to a *different* account later.
  static Future<void> migrateString(SharedPreferences prefs, String base) =>
      _migrate(prefs, base, (v) => prefs.setString(key(base), v as String));

  static Future<void> migrateBool(SharedPreferences prefs, String base) =>
      _migrate(prefs, base, (v) => prefs.setBool(key(base), v as bool));

  static Future<void> _migrate(
    SharedPreferences prefs,
    String base,
    Future<void> Function(Object value) write,
  ) async {
    if (currentUid == null) return;
    final scopedKey = key(base);
    if (prefs.containsKey(scopedKey) || !prefs.containsKey(base)) return;
    final value = prefs.get(base);
    if (value == null) return;
    await write(value);
    await prefs.remove(base);
  }
}
