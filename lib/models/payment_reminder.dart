class PaymentReminder {
  const PaymentReminder({
    required this.id,
    required this.title,
    this.amount,
    required this.dayOfMonth,
    this.oneTimeDate,
    required this.hour,
    required this.minute,
    required this.repeatMonthly,
    required this.enabled,
  });

  final String id;
  final String title;
  final double? amount;
  /// Day of the month (1–31) used when [repeatMonthly] is true.
  final int dayOfMonth;
  /// Full date for one-time reminders.
  final DateTime? oneTimeDate;
  final int hour;
  final int minute;
  final bool repeatMonthly;
  final bool enabled;

  int get notificationId => id.hashCode.abs() % 2147483647;

  PaymentReminder copyWith({
    String? id,
    String? title,
    double? amount,
    bool clearAmount = false,
    int? dayOfMonth,
    DateTime? oneTimeDate,
    bool clearOneTimeDate = false,
    int? hour,
    int? minute,
    bool? repeatMonthly,
    bool? enabled,
  }) {
    return PaymentReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: clearAmount ? null : (amount ?? this.amount),
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      oneTimeDate:
          clearOneTimeDate ? null : (oneTimeDate ?? this.oneTimeDate),
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatMonthly: repeatMonthly ?? this.repeatMonthly,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dayOfMonth': dayOfMonth,
        'oneTimeDate': oneTimeDate?.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'repeatMonthly': repeatMonthly,
        'enabled': enabled,
      };

  factory PaymentReminder.fromJson(Map<String, dynamic> json) {
    final oneTimeRaw = json['oneTimeDate'];
    return PaymentReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      dayOfMonth: json['dayOfMonth'] as int? ?? 1,
      oneTimeDate: oneTimeRaw == null ? null : DateTime.parse(oneTimeRaw as String),
      hour: json['hour'] as int? ?? 9,
      minute: json['minute'] as int? ?? 0,
      repeatMonthly: json['repeatMonthly'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
