import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/update_expense.dart';
import '../../../../core/usecase/usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

@injectable
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final DeleteExpense deleteExpense;
  final UpdateExpense updateExpense;

  ExpenseBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.deleteExpense,
    required this.updateExpense,
  }) : super(ExpenseInitial()) {
    on<LoadExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await getExpenses(NoParams());
        emit(ExpenseLoaded(expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<AddExpenseEvent> ((event, emit) async {
      try {
        await addExpense(event.expense);
        add(LoadExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<DeleteExpenseEvent>((event, emit) async {
      try {
        await deleteExpense(event.id);
        add(LoadExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<UpdateExpenseEvent>((event, emit) async {
      try {
        await updateExpense(event.expense);
        add(LoadExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}
