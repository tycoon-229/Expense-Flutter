import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.type = TransactionType.expense,
  });

  @override
  List<Object?> get props => [id, title, amount, date, category, type];
}
