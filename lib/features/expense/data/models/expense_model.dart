import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    super.categoryId,
    super.categoryName,
    super.categoryColor,
    super.categoryIcon,
    required super.type,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    String? categoryName;
    String? categoryColor;
    String? categoryIcon;

    // Đọc tên, màu và icon từ object categories JOIN về
    if (json['categories'] != null && json['categories'] is Map) {
      categoryName = json['categories']['name'] as String?;
      categoryColor = json['categories']['color'] as String?;
      categoryIcon = json['categories']['icon'] as String?;
    }

    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      categoryId: json['category_id'] as String?,
      categoryName: categoryName,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'type': type == TransactionType.income ? 'income' : 'expense',
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      categoryId: expense.categoryId,
      categoryName: expense.categoryName,
      categoryColor: expense.categoryColor,
      categoryIcon: expense.categoryIcon,
      type: expense.type,
    );
  }
}