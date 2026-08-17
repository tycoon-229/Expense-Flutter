import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_summary_chart.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExpenseBloc>()..add(LoadExpenses()),
      child: const ExpenseListView(),
    );
  }
}

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Chi phí'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 30
        ),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          )
        ),
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExpenseLoaded) {
              final expenses = state.expenses;
              final totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);
              if (expenses.isEmpty) {
                return const Center(
                  child: Text(
                      'Chưa có khoản phi phí nào. Hãy thêm vào nhé!',
                  ),
                );
              }
              return Column(
                children: [
                  FadeInDown(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Phân bổ chi phí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ExpenseSummaryChart(expenses: expenses),
                              const SizedBox(height: 10),
                              Text(
                                'Tổng chi tiêu: ${NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: 'VNĐ',
                                  decimalDigits: 0,
                                ).format(totalAmount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return FadeInLeft(
                          delay: Duration(milliseconds: 100 * index),
                          child: Dismissible(
                            key: Key(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                onLongPress: () async {
                                  final updatedExpense = await context.push<Expense>(
                                    '/edit',
                                    extra: expense,
                                  );
                                  if (updatedExpense != null && context.mounted) {
                                    context.read<ExpenseBloc>().add(UpdateExpenseEvent(updatedExpense));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    _getIcon(expense.category),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(DateFormat('dd MMM yyyy').format(expense.date)),
                                trailing: Text(
                                  NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: 'VNĐ',
                                    decimalDigits: 0,
                                  ).format(expense.amount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is ExpenseError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final expense = await context.push<Expense>('/add');
          if (expense != null && context.mounted) {
            context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'đồ ăn': return Icons.restaurant;
      case 'đi lại': return Icons.directions_bus;
      case 'mua sắm': return Icons.shopping_bag;
      case 'hóa đơn': return Icons.receipt_long;
      default: return Icons.category;
    }
  }
}
