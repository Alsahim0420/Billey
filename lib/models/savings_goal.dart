import 'savings_goal_style.dart';

/// A savings goal, stored in Firestore under `users/{uid}/goals/{id}` so a
/// linked partner can see the ones explicitly shared with them (via
/// [sharedWith]), the same way shared transactions work.
class SavingsGoal {
  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double targetAmount;
  final int monthsLeft;
  final SavingsGoalStyle style;
  final List<String> sharedWith;
  final String? ownerId;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthsLeft,
    required this.style,
    this.sharedWith = const [],
    this.ownerId,
  });

  double get progress => targetAmount <= 0 ? 0 : currentAmount / targetAmount;

  SavingsGoal copyWith({List<String>? sharedWith}) {
    return SavingsGoal(
      id: id,
      title: title,
      subtitle: subtitle,
      currentAmount: currentAmount,
      targetAmount: targetAmount,
      monthsLeft: monthsLeft,
      style: style,
      sharedWith: sharedWith ?? this.sharedWith,
      ownerId: ownerId,
    );
  }

  Map<String, dynamic> toFirestore({required String userId}) {
    return {
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'monthsLeft': monthsLeft,
      'style': style.name,
      'sharedWith': sharedWith,
    };
  }

  factory SavingsGoal.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return SavingsGoal(
      id: documentId,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String,
      currentAmount: (data['currentAmount'] as num).toDouble(),
      targetAmount: (data['targetAmount'] as num).toDouble(),
      monthsLeft: data['monthsLeft'] as int,
      style: SavingsGoalStyle.fromName(data['style'] as String),
      sharedWith: (data['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ownerId: data['userId'] as String?,
    );
  }
}
