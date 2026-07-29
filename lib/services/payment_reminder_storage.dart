import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_reminder.dart';

class PaymentReminderStorage {
  static const _storageKey = 'billey_payment_reminders';

  Future<List<PaymentReminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => PaymentReminder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<PaymentReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
