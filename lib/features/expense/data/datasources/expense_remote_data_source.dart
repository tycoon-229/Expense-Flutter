import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

@LazySingleton(as: ExpenseRemoteDataSource)
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient supabase;

  ExpenseRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await supabase
        .from('expenses')
        .select('*, categories(name, color, icon)')
        .order('date', ascending: false);

    return (response as List).map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = expense.toJson()..['user_id'] = userId;
    await supabase.from('expenses').insert(data);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await supabase
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await supabase.from('expenses').delete().eq('id', id);
  }
}