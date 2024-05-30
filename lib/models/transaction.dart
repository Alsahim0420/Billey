class TransactionModel {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values
          .firstWhere((e) => e.toString().split('.').last == map['type']),
    );
  }
}

enum TransactionType { ingreso, gasto }
