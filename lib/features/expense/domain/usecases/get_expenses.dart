import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class GetExpenses implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  Future<List<Expense>> call(NoParams params) {
    return repository.getExpenses();
  }
}
