import 'package:go_router/go_router.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/presentation/pages/expense_list_page.dart';
import '../../features/expense/presentation/pages/add_expense_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ExpenseListPage(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddExpensePage(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final expense = state.extra as Expense?;
          return AddExpensePage(expense: expense);
        },
      ),
    ],
  );
}
