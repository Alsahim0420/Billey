import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/colors/app_colors.dart';

class ThemeSettingsProvider extends ChangeNotifier {
  static const _storageKey = 'billey_dark_mode_enabled';

  bool _isDarkMode = true;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeSettingsProvider();

  /// Cargar preferencia antes de [runApp] para evitar parpadeo.
  Future<void> initialize() async {
    if (_isLoaded) return;
    await _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_storageKey) ?? true;
    AppColors.isDarkMode = _isDarkMode;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;

    _isDarkMode = enabled;
    AppColors.isDarkMode = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, enabled);

    notifyListeners();
  }
}
