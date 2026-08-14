import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<void> call(String id) {
    return repository.deleteExpense(id);
  }
}
