import 'package:flutter/foundation.dart';

import '../models/savings_goal.dart';
import '../services/firestore_goals_service.dart';

/// Savings goals, sourced from Firestore so a linked partner can see the
/// ones shared with them — mirrors [TransactionProvider]'s cloud + partner
/// merge pattern.
class GoalsProvider extends ChangeNotifier {
  GoalsProvider({FirestoreGoalsService? service})
      : _service = service ?? FirestoreGoalsService();

  final FirestoreGoalsService _service;
  List<SavingsGoal> _goals = [];
  String? _partnerUid;
  bool _isLoaded = false;

  List<SavingsGoal> get goals => _goals;
  bool get isLoaded => _isLoaded;

  double get totalSavings =>
      _goals.fold(0, (total, goal) => total + goal.currentAmount);

  /// Sets (or clears) the linked partner's uid so [load] also pulls in
  /// whatever goals they've shared with us. Reloads immediately if changed.
  void setPartnerUid(String? partnerUid) {
    if (_partnerUid == partnerUid) return;
    _partnerUid = partnerUid;
    load();
  }

  Future<void> load() async {
    var data = await _service.readAll();
    final partnerUid = _partnerUid;
    if (partnerUid != null) {
      final shared = await _service.readSharedByPartner(partnerUid);
      data = [...data, ...shared];
    }
    _goals = data;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> create(SavingsGoal goal) async {
    await _service.create(goal);
    await load();
  }

  Future<void> update(SavingsGoal goal) async {
    await _service.update(goal);
    await load();
  }

  Future<void> delete(String id) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    final removed = index == -1 ? null : _goals.removeAt(index);
    notifyListeners();

    try {
      await _service.delete(id);
    } catch (_) {
      if (removed != null) {
        _goals.insert(index.clamp(0, _goals.length), removed);
        notifyListeners();
      }
      rethrow;
    }
  }
}
