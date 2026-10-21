import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final TransactionType type;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.type = TransactionType.expense,
  });

  @override
  List<Object?> get props => [id, title, amount, date, categoryId, categoryName, categoryColor, categoryIcon, type];
}