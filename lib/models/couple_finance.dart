class CoupleLink {
  const CoupleLink({
    required this.spaceId,
    required this.secret,
    required this.myName,
    required this.partnerName,
    required this.linkedAt,
  });

  final String spaceId;
  final String secret;
  final String myName;
  final String partnerName;
  final DateTime linkedAt;

  Map<String, dynamic> toJson() => {
        'spaceId': spaceId,
        'secret': secret,
        'myName': myName,
        'partnerName': partnerName,
        'linkedAt': linkedAt.toIso8601String(),
      };

  factory CoupleLink.fromJson(Map<String, dynamic> json) {
    return CoupleLink(
      spaceId: json['spaceId'] as String,
      secret: json['secret'] as String,
      myName: json['myName'] as String,
      partnerName: json['partnerName'] as String,
      linkedAt: DateTime.parse(json['linkedAt'] as String),
    );
  }
}

class SharedWalletExpense {
  const SharedWalletExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.spentBy,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final String spentBy;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'spentBy': spentBy,
        'date': date.toIso8601String(),
      };

  factory SharedWalletExpense.fromJson(Map<String, dynamic> json) {
    return SharedWalletExpense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      spentBy: json['spentBy'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class SharedWallet {
  const SharedWallet({
    required this.id,
    required this.title,
    required this.budget,
    required this.holderName,
    required this.senderName,
    required this.createdAt,
    required this.updatedAt,
    required this.expenses,
  });

  final String id;
  final String title;
  final double budget;
  final String holderName;
  final String senderName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SharedWalletExpense> expenses;

  double get spent =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  double get remaining => budget - spent;

  SharedWallet copyWith({
    String? title,
    double? budget,
    String? holderName,
    String? senderName,
    DateTime? updatedAt,
    List<SharedWalletExpense>? expenses,
  }) {
    return SharedWallet(
      id: id,
      title: title ?? this.title,
      budget: budget ?? this.budget,
      holderName: holderName ?? this.holderName,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'budget': budget,
        'holderName': holderName,
        'senderName': senderName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'expenses': expenses.map((expense) => expense.toJson()).toList(),
      };

  factory SharedWallet.fromJson(Map<String, dynamic> json) {
    final expensesJson = json['expenses'] as List<dynamic>? ?? [];
    return SharedWallet(
      id: json['id'] as String,
      title: json['title'] as String,
      budget: (json['budget'] as num).toDouble(),
      holderName: json['holderName'] as String,
      senderName: json['senderName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expenses: expensesJson
          .map(
            (item) =>
                SharedWalletExpense.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
