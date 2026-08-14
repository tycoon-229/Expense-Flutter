import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<void> call(Expense expense) {
    return repository.updateExpense(expense);
  }
}
