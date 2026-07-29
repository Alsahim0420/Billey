import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Persisted app language. `null` = follow system locale.
class LocaleSettingsProvider extends ChangeNotifier {
  static const _storageKey = 'billey_app_locale';

  Locale? _locale;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Locale? get locale => _locale;

  LocaleSettingsProvider();

  Future<void> initialize() async {
    if (_isLoaded) return;
    await _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code == null || code.isEmpty || code == 'system') {
      _locale = null;
    } else {
      _locale = Locale(code);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_storageKey, 'system');
    } else {
      await prefs.setString(_storageKey, locale.languageCode);
    }
    notifyListeners();
  }

  String languageLabel(AppLocalizations l10n) {
    if (_locale == null) return l10n.languageSystem;
    return switch (_locale!.languageCode) {
      'es' => l10n.languageSpanish,
      'en' => l10n.languageEnglish,
      _ => _locale!.languageCode,
    };
  }
}
