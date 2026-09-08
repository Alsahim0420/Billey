import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_reminder.dart';
import 'user_scope.dart';

class PaymentReminderStorage {
  static const _storageKey = 'billey_payment_reminders';

  Future<List<PaymentReminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    await UserScope.migrateString(prefs, _storageKey);
    final raw = prefs.getString(UserScope.key(_storageKey));
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => PaymentReminder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<PaymentReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(UserScope.key(_storageKey), encoded);
  }
}
