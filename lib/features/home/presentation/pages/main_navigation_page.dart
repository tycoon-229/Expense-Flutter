import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../category/presentation/pages/category_management_page.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../expense/presentation/bloc/expense_event.dart';
import '../../../expense/presentation/pages/expense_list_page.dart';
import '../../../expense/presentation/pages/expense_analytics_page.dart';

import '../../../recurring/presentation/pages/recurring_transactions_page.dart';
import '../../../recurring/data/datasources/recurring_local_data_source.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late final ExpenseBloc _expenseBloc;

  final List<Widget> _pages = const [
    ExpenseListPage(),
    ExpenseAnalyticsPage(),
    CategoryManagementPage(),
    RecurringTransactionsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _expenseBloc = getIt<ExpenseBloc>()..add(LoadExpenses());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRecurringExpenses();
    });
  }

  Future<void> _checkRecurringExpenses() async {
    final due = await RecurringLocalDataSource().checkAndGenerateDueExpenses();
    if (due.isNotEmpty) {
      for (final e in due) {
        _expenseBloc.add(AddExpenseEvent(e));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Đã tự động ghi nhận ${due.length} khoản thu chi cố định tháng này!'),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _expenseBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _expenseBloc,
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Colors.deepPurple.shade100,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    );
                  }
                  return TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                elevation: 8,
                backgroundColor: Colors.white,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long, color: Colors.deepPurple),
                    label: 'Sổ chi tiêu',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart, color: Colors.deepPurple),
                    label: 'Thống kê',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.category_outlined),
                    selectedIcon: Icon(Icons.category, color: Colors.deepPurple),
                    label: 'Danh mục',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.repeat_outlined),
                    selectedIcon: Icon(Icons.repeat_rounded, color: Colors.deepPurple),
                    label: 'Cố định',
                  ),
                ],
              ),
            ),
            floatingActionButton: _currentIndex < 2
                ? FloatingActionButton(
                    backgroundColor: Colors.deepPurple,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () async {
                      final newExpense = await context.push<Expense>('/add');
                      if (newExpense != null && context.mounted) {
                        context.read<ExpenseBloc>().add(AddExpenseEvent(newExpense));
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  )
                : null,
          );
        },
      ),
    );
  }
}
