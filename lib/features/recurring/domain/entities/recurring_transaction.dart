import 'dart:convert';
import '../../../expense/domain/entities/expense.dart';

class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final int dayOfMonth; // Ngày trong tháng (1 - 31)
  final bool isActive;
  final String? lastExecutedMonth; // Format 'YYYY-MM'

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    required this.dayOfMonth,
    this.isActive = true,
    this.lastExecutedMonth,
  });

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? categoryColor,
    String? categoryIcon,
    int? dayOfMonth,
    bool? isActive,
    String? lastExecutedMonth,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      lastExecutedMonth: lastExecutedMonth ?? this.lastExecutedMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryColor': categoryColor,
      'categoryIcon': categoryIcon,
      'dayOfMonth': dayOfMonth,
      'isActive': isActive,
      'lastExecutedMonth': lastExecutedMonth,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: map['categoryId'] as String?,
      categoryName: map['categoryName'] as String?,
      categoryColor: map['categoryColor'] as String?,
      categoryIcon: map['categoryIcon'] as String?,
      dayOfMonth: map['dayOfMonth'] as int? ?? 1,
      isActive: map['isActive'] as bool? ?? true,
      lastExecutedMonth: map['lastExecutedMonth'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecurringTransaction.fromJson(String source) =>
      RecurringTransaction.fromMap(json.decode(source) as Map<String, dynamic>);
}
