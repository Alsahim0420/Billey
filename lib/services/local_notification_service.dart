import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/payment_reminder.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'billey_payment_reminders';
  static const _channelName = 'Payment reminders';
  static const _channelDescription = 'Reminders for upcoming payments';

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> schedulePaymentReminder({
    required PaymentReminder reminder,
    required String body,
  }) async {
    await initialize();
    await cancelPaymentReminder(reminder);

    if (!reminder.enabled) return;

    final scheduled = _nextScheduleDate(reminder);
    if (scheduled == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: reminder.notificationId,
      title: reminder.title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          reminder.repeatMonthly ? DateTimeComponents.dayOfMonthAndTime : null,
    );
  }

  Future<void> cancelPaymentReminder(PaymentReminder reminder) async {
    await initialize();
    await _plugin.cancel(id: reminder.notificationId);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  tz.TZDateTime? _nextScheduleDate(PaymentReminder reminder) {
    final now = tz.TZDateTime.now(tz.local);

    if (reminder.repeatMonthly) {
      final day = reminder.dayOfMonth.clamp(1, 31);
      var scheduled = _safeDateTime(
          now.year, now.month, day, reminder.hour, reminder.minute);
      if (!scheduled.isAfter(now)) {
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        scheduled = _safeDateTime(
          nextYear,
          nextMonth,
          day,
          reminder.hour,
          reminder.minute,
        );
      }
      return scheduled;
    }

    final date = reminder.oneTimeDate;
    if (date == null) return null;

    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      reminder.hour,
      reminder.minute,
    );
    if (!scheduled.isAfter(now)) return null;
    return scheduled;
  }

  tz.TZDateTime _safeDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = day.clamp(1, lastDay);
    return tz.TZDateTime(tz.local, year, month, safeDay, hour, minute);
  }
}
