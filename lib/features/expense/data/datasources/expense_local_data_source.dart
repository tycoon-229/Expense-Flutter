import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> cacheExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

@LazySingleton(as: ExpenseLocalDataSource)
class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const String boxName = 'expenses';

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final box = await Hive.openBox<ExpenseModel>(boxName);
    return box.values.toList();
  }

  @override
  Future<void> cacheExpense(ExpenseModel expense) async {
    final box = await Hive.openBox<ExpenseModel>(boxName);
    await box.put(expense.id, expense);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final box = await Hive.openBox<ExpenseModel>(boxName);
    await box.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final box = await Hive.openBox<ExpenseModel>(boxName);
    await box.delete(id);
  }
}
