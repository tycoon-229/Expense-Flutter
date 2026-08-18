import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends Expense {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String category;
  @HiveField(5)
  final String? typeString;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.typeString,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          date: date,
          category: category,
          type: typeString == 'income' ? TransactionType.income : TransactionType.expense,
        );

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      typeString: expense.type.name,
    );
  }

  @override
  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      type: typeString == 'income' ? TransactionType.income : TransactionType.expense,
    );
  }
}
