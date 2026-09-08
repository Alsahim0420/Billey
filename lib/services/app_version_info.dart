import 'package:package_info_plus/package_info_plus.dart';

/// The app's real version/build number, read straight from the platform
/// (which mirrors `pubspec.yaml`'s `version:` field at build time) instead
/// of a hand-typed string that silently goes stale on every release.
class AppVersionInfo {
  AppVersionInfo._();

  static Future<PackageInfo>? _cached;

  /// Cached after the first call — the underlying platform channel result
  /// never changes for the lifetime of the running app.
  static Future<PackageInfo> load() {
    return _cached ??= PackageInfo.fromPlatform();
  }
}
