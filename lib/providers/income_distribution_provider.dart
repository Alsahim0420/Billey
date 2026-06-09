import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeDistributionProvider extends ChangeNotifier {
  static const _selectedTemplateKey = 'income_distribution_selected_template';
  static const _autoEnabledKey = 'income_distribution_auto_enabled';
  static const _customBucketsKey = 'income_distribution_custom_buckets';

  static const customTemplateId = 'custom';

  static const List<IncomeDistributionTemplate> templates = [
    IncomeDistributionTemplate(
      id: 'balanced_50_30_20',
      name: '50/30/20 Balanceado',
      subtitle: 'Necesidades, gustos y ahorro',
      buckets: [
        DistributionBucket(
          id: 'essentials',
          label: 'Essentials',
          percent: 50,
          iconKey: 'home',
          colorValue: 0xFF2D6CDF,
        ),
        DistributionBucket(
          id: 'wants',
          label: 'Wants',
          percent: 30,
          iconKey: 'bag',
          colorValue: 0xFF8B4DD7,
        ),
        DistributionBucket(
          id: 'savings',
          label: 'Savings',
          percent: 20,
          iconKey: 'pig',
          colorValue: 0xFF0EA56A,
        ),
      ],
    ),
    IncomeDistributionTemplate(
      id: 'debt_first',
      name: 'Deudas primero',
      subtitle: 'Agrega un sobre dedicado a deudas',
      buckets: [
        DistributionBucket(
          id: 'essentials',
          label: 'Essentials',
          percent: 50,
          iconKey: 'home',
          colorValue: 0xFF2D6CDF,
        ),
        DistributionBucket(
          id: 'wants',
          label: 'Wants',
          percent: 20,
          iconKey: 'bag',
          colorValue: 0xFF8B4DD7,
        ),
        DistributionBucket(
          id: 'debt',
          label: 'Debts',
          percent: 20,
          iconKey: 'receipt',
          colorValue: 0xFFFF6B6B,
        ),
        DistributionBucket(
          id: 'savings',
          label: 'Savings',
          percent: 10,
          iconKey: 'pig',
          colorValue: 0xFF0EA56A,
        ),
      ],
    ),
    IncomeDistributionTemplate(
      id: 'investor',
      name: 'Modo inversionista',
      subtitle: 'Ahorro separado de inversión',
      buckets: [
        DistributionBucket(
          id: 'essentials',
          label: 'Essentials',
          percent: 45,
          iconKey: 'home',
          colorValue: 0xFF2D6CDF,
        ),
        DistributionBucket(
          id: 'wants',
          label: 'Wants',
          percent: 15,
          iconKey: 'bag',
          colorValue: 0xFF8B4DD7,
        ),
        DistributionBucket(
          id: 'investing',
          label: 'Investing',
          percent: 25,
          iconKey: 'trend',
          colorValue: 0xFF1FAD98,
        ),
        DistributionBucket(
          id: 'savings',
          label: 'Savings',
          percent: 15,
          iconKey: 'pig',
          colorValue: 0xFF0EA56A,
        ),
      ],
    ),
    IncomeDistributionTemplate(
      id: 'variable_income',
      name: 'Ingreso variable',
      subtitle: 'Incluye colchón para meses flojos',
      buckets: [
        DistributionBucket(
          id: 'essentials',
          label: 'Essentials',
          percent: 60,
          iconKey: 'home',
          colorValue: 0xFF2D6CDF,
        ),
        DistributionBucket(
          id: 'buffer',
          label: 'Buffer',
          percent: 20,
          iconKey: 'shield',
          colorValue: 0xFF5DF3E6,
        ),
        DistributionBucket(
          id: 'wants',
          label: 'Wants',
          percent: 10,
          iconKey: 'bag',
          colorValue: 0xFF8B4DD7,
        ),
        DistributionBucket(
          id: 'savings',
          label: 'Savings',
          percent: 10,
          iconKey: 'pig',
          colorValue: 0xFF0EA56A,
        ),
      ],
    ),
  ];

  bool _isLoaded = false;
  bool _autoEnabled = true;
  String _selectedTemplateId = 'balanced_50_30_20';
  List<DistributionBucket> _customBuckets = templates.first.buckets;

  bool get isLoaded => _isLoaded;
  bool get autoEnabled => _autoEnabled;
  String get selectedTemplateId => _selectedTemplateId;

  IncomeDistributionTemplate get activeTemplate {
    if (_selectedTemplateId == customTemplateId) {
      return IncomeDistributionTemplate(
        id: customTemplateId,
        name: 'Personalizada',
        subtitle: 'Tu propia regla de distribución',
        buckets: _customBuckets,
        isCustom: true,
      );
    }

    return templates.firstWhere(
      (template) => template.id == _selectedTemplateId,
      orElse: () => templates.first,
    );
  }

  IncomeDistributionProvider() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _autoEnabled = prefs.getBool(_autoEnabledKey) ?? true;
    _selectedTemplateId =
        prefs.getString(_selectedTemplateKey) ?? 'balanced_50_30_20';
    _customBuckets = _decodeBuckets(prefs.getString(_customBucketsKey)) ??
        templates.first.buckets;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setAutoEnabled(bool enabled) async {
    _autoEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoEnabledKey, enabled);
  }

  Future<void> selectTemplate(String templateId) async {
    if (templateId != customTemplateId &&
        !templates.any((template) => template.id == templateId)) {
      return;
    }

    _selectedTemplateId = templateId;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTemplateKey, templateId);
  }

  Future<void> saveCustomBuckets(
    List<DistributionBucket> buckets, {
    bool selectCustom = true,
  }) async {
    _customBuckets = buckets
        .map((bucket) =>
            bucket.copyWith(percent: bucket.percent.roundToDouble()))
        .toList();
    if (selectCustom) {
      _selectedTemplateId = customTemplateId;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customBucketsKey, jsonEncode(_customBuckets));
    if (selectCustom) {
      await prefs.setString(_selectedTemplateKey, customTemplateId);
    }
  }

  Future<void> saveCustom({
    required double essentials,
    required double wants,
    required double savings,
    bool selectCustom = true,
  }) {
    return saveCustomBuckets(
      [
        DistributionBucket(
          id: 'essentials',
          label: 'Essentials',
          percent: essentials,
          iconKey: 'home',
          colorValue: 0xFF2D6CDF,
        ),
        DistributionBucket(
          id: 'wants',
          label: 'Wants',
          percent: wants,
          iconKey: 'bag',
          colorValue: 0xFF8B4DD7,
        ),
        DistributionBucket(
          id: 'savings',
          label: 'Savings',
          percent: savings,
          iconKey: 'pig',
          colorValue: 0xFF0EA56A,
        ),
      ],
      selectCustom: selectCustom,
    );
  }

  List<DistributionBucket>? _decodeBuckets(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    try {
      final data = jsonDecode(raw) as List<dynamic>;
      final buckets = data
          .map((item) =>
              DistributionBucket.fromJson(item as Map<String, dynamic>))
          .toList();
      return buckets.isEmpty ? null : buckets;
    } catch (_) {
      return null;
    }
  }
}

class IncomeDistributionTemplate {
  final String id;
  final String name;
  final String subtitle;
  final List<DistributionBucket> buckets;
  final bool isCustom;

  const IncomeDistributionTemplate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.buckets,
    this.isCustom = false,
  });

  double get total => buckets.fold(0, (sum, bucket) => sum + bucket.percent);
  bool get isValid => total.round() == 100;
  double get essentials => _bucketPercent('essentials');
  double get wants => _bucketPercent('wants');
  double get savings => _bucketPercent('savings');

  String get ratioLabel =>
      buckets.map((bucket) => bucket.percent.round().toString()).join('/');

  double _bucketPercent(String id) {
    for (final bucket in buckets) {
      if (bucket.id == id) return bucket.percent;
    }
    return 0;
  }
}

class DistributionBucket {
  final String id;
  final String label;
  final double percent;
  final String iconKey;
  final int colorValue;

  const DistributionBucket({
    required this.id,
    required this.label,
    required this.percent,
    required this.iconKey,
    required this.colorValue,
  });

  DistributionBucket copyWith({
    String? id,
    String? label,
    double? percent,
    String? iconKey,
    int? colorValue,
  }) {
    return DistributionBucket(
      id: id ?? this.id,
      label: label ?? this.label,
      percent: percent ?? this.percent,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'percent': percent,
      'iconKey': iconKey,
      'colorValue': colorValue,
    };
  }

  factory DistributionBucket.fromJson(Map<String, dynamic> json) {
    return DistributionBucket(
      id: (json['id'] as String?) ?? 'custom',
      label: (json['label'] as String?) ?? 'Custom',
      percent: ((json['percent'] as num?) ?? 0).toDouble(),
      iconKey: (json['iconKey'] as String?) ?? 'wallet',
      colorValue: (json['colorValue'] as int?) ?? 0xFF1FAD98,
    );
  }
}
