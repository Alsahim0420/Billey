import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A device-level display preference. Never changes amounts or input formatting.
class AmountVisibilityProvider extends ChangeNotifier {
  static const _key = 'billey_amounts_hidden';
  bool _hidden = false;
  bool get hidden => _hidden;
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hidden = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _hidden = !_hidden;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _hidden);
  }
}
