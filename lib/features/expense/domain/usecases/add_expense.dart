import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class AddExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<void> call(Expense expense) {
    return repository.addExpense(expense);
  }
}
