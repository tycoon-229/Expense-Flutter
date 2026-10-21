import 'package:injectable/injectable.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await remoteDataSource.getExpenses();
    return models;
  }

  @override
  Future<void> addExpense(Expense expense) {
    return remoteDataSource.addExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> updateExpense(Expense expense) {
    return remoteDataSource.updateExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) {
    return remoteDataSource.deleteExpense(id);
  }
}
