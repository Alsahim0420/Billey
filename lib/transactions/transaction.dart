import 'package:uuid/uuid.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  }) : id = const Uuid().v4();
}
