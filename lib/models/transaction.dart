import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../theme/colors/app_colors.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final TransactionCategory category;

  @HiveField(6)
  final String? description;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values
          .firstWhere((e) => e.toString().split('.').last == map['type']),
      category: TransactionCategory.values.firstWhere(
          (e) => e.toString().split('.').last == (map['category'] ?? 'other')),
      description: map['description'],
    );
  }
}

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  ingreso,
  @HiveField(1)
  gasto,
}

@HiveType(typeId: 2)
enum TransactionCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  health,
  @HiveField(4)
  education,
  @HiveField(5)
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Comida';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.entertainment:
        return 'Entretenimiento';
      case TransactionCategory.health:
        return 'Salud';
      case TransactionCategory.education:
        return 'Educación';
      case TransactionCategory.other:
        return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.health:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return AppColors.categoryFood;
      case TransactionCategory.transport:
        return AppColors.categoryTransport;
      case TransactionCategory.entertainment:
        return AppColors.categoryEntertainment;
      case TransactionCategory.health:
        return AppColors.categoryHealth;
      case TransactionCategory.education:
        return AppColors.categoryEducation;
      case TransactionCategory.other:
        return AppColors.categoryOther;
    }
  }
}
