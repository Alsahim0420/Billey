import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/payment_reminder.dart';
import '../services/local_notification_service.dart';
import '../services/payment_reminder_storage.dart';

class PaymentReminderProvider extends ChangeNotifier {
  PaymentReminderProvider({
    PaymentReminderStorage? storage,
    LocalNotificationService? notificationService,
  })  : _storage = storage ?? PaymentReminderStorage(),
        _notifications = notificationService ?? LocalNotificationService.instance;

  final PaymentReminderStorage _storage;
  final LocalNotificationService _notifications;
  final _uuid = const Uuid();

  List<PaymentReminder> _reminders = [];
  bool _isLoaded = false;

  List<PaymentReminder> get reminders {
    final sorted = List<PaymentReminder>.from(_reminders);
    sorted.sort(_compareReminders);
    return List.unmodifiable(sorted);
  }

  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    await _notifications.initialize();
    _reminders = await _storage.loadAll();
    _isLoaded = true;
    await _rescheduleAll(
      notificationBodyBuilder: _defaultNotificationBody,
    );
    notifyListeners();
  }

  Future<bool> requestPermissions() => _notifications.requestPermissions();

  Future<void> addReminder(
    PaymentReminder reminder, {
    required String Function(PaymentReminder reminder) notificationBodyBuilder,
  }) async {
    _reminders = [..._reminders, reminder];
    await _persistAndSchedule(notificationBodyBuilder);
  }

  Future<void> updateReminder(
    PaymentReminder reminder, {
    required String Function(PaymentReminder reminder) notificationBodyBuilder,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index == -1) return;
    _reminders[index] = reminder;
    await _persistAndSchedule(notificationBodyBuilder);
  }

  Future<void> deleteReminder(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    _reminders.removeWhere((r) => r.id == id);
    await _notifications.cancelPaymentReminder(reminder);
    await _storage.saveAll(_reminders);
    notifyListeners();
  }

  Future<void> toggleEnabled(
    String id, {
    required String Function(PaymentReminder reminder) notificationBodyBuilder,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updated = _reminders[index].copyWith(
      enabled: !_reminders[index].enabled,
    );
    _reminders[index] = updated;
    await _persistAndSchedule(notificationBodyBuilder);
  }

  PaymentReminder createDraft({
    PaymentReminder? existing,
  }) {
    if (existing != null) return existing;
    final now = DateTime.now();
    return PaymentReminder(
      id: _uuid.v4(),
      title: '',
      amount: null,
      dayOfMonth: now.day,
      oneTimeDate: DateTime(now.year, now.month, now.day),
      hour: 9,
      minute: 0,
      repeatMonthly: true,
      enabled: true,
    );
  }

  Future<void> _persistAndSchedule(
    String Function(PaymentReminder reminder) notificationBodyBuilder,
  ) async {
    await _storage.saveAll(_reminders);
    await _rescheduleAll(notificationBodyBuilder: notificationBodyBuilder);
    notifyListeners();
  }

  Future<void> _rescheduleAll({
    required String Function(PaymentReminder reminder) notificationBodyBuilder,
  }) async {
    await _notifications.cancelAll();
    for (final reminder in _reminders) {
      if (!reminder.enabled) continue;
      await _notifications.schedulePaymentReminder(
        reminder: reminder,
        body: notificationBodyBuilder(reminder),
      );
    }
  }

  String _defaultNotificationBody(PaymentReminder reminder) {
    if (reminder.amount != null) {
      return '${reminder.title}: ${reminder.amount!.toStringAsFixed(0)}';
    }
    return reminder.title;
  }

  int _compareReminders(PaymentReminder a, PaymentReminder b) {
    if (a.repeatMonthly != b.repeatMonthly) {
      return a.repeatMonthly ? -1 : 1;
    }
    if (a.repeatMonthly) {
      return a.dayOfMonth.compareTo(b.dayOfMonth);
    }
    final aDate = a.oneTimeDate;
    final bDate = b.oneTimeDate;
    if (aDate == null || bDate == null) return 0;
    return aDate.compareTo(bDate);
  }
}
