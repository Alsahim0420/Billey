import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_cycle.dart';

/// Preferences are isolated by account, just like the local category catalog.
class FinancialCycleProvider extends ChangeNotifier {
  FinancialCycle cycle = const FinancialCycle();
  bool configured = false;
  bool loaded = false;
  String? _owner;
  int _generation = 0;
  Future<void> bindUser(String? owner) async {
    final generation = ++_generation;
    _owner = owner;
    cycle = const FinancialCycle();
    configured = false;
    loaded = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (generation != _generation) return;
    final day =
        owner == null ? null : prefs.getInt('financial_cycle_start_$owner');
    if (day != null && day >= 1 && day <= 31) {
      cycle = FinancialCycle(day);
      configured = true;
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> save(int day) async {
    if (day < 1 || day > 31) throw ArgumentError.value(day);
    final owner = _owner;
    final generation = _generation;
    if (owner == null) throw StateError('Inicia sesión para guardar tu ciclo.');
    final prefs = await SharedPreferences.getInstance();
    if (generation != _generation) throw StateError('La cuenta cambió.');
    if (!await prefs.setInt('financial_cycle_start_$owner', day)) {
      throw StateError('No se pudo guardar el ciclo.');
    }
    if (generation != _generation) return;
    cycle = FinancialCycle(day);
    configured = true;
    notifyListeners();
  }
}
