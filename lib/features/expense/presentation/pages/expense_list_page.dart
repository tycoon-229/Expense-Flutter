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

class ExpenseListView extends StatefulWidget {
  const ExpenseListView({super.key});

  @override
  State<ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<ExpenseListView> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THEO DÕI THU - CHI'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
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
              final totalIncome = expenses
                  .where((e) => e.type == TransactionType.income)
                  .fold(0.0, (sum, item) => sum + item.amount);
              final totalExpense = expenses
                  .where((e) => e.type == TransactionType.expense)
                  .fold(0.0, (sum, item) => sum + item.amount);
              final balance = totalIncome - totalExpense;

              if (expenses.isEmpty) {
                return const Center(
                  child: Text(
                      'CHƯA CÓ DỮ LIỆU, HÃY THÊM VÀO NHÉ!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }
              return Column(
                children: [
                  FadeInDown(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.analytics_outlined, color: Colors.blueGrey, size: 20),
                                  SizedBox(width: 8),
                                  Text('TÓM TẮT TÀI CHÍNH',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSummaryItem('THU NHẬP', totalIncome, Colors.green),
                                    Container(width: 1, height: 30, color: Colors.grey[300]),
                                    _buildSummaryItem('CHI TIÊU', totalExpense, Colors.red),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Align(
                                alignment: Alignment.center,
                                child: Text('PHÂN BỔ CHI TIÊU',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey
                                  )
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ExpenseSummaryChart(
                                  expenses: expenses,
                                  onCategorySelected: (category) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: balance >= 0 
                                      ? [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.05)]
                                      : [Colors.red.withValues(alpha: 0.1), Colors.red.withValues(alpha: 0.05)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: balance >= 0 ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('SỐ DƯ', 
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.1)),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: 'VNĐ',
                                        decimalDigits: 0,
                                      ).format(balance),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: balance >= 0 ? Colors.green[800] : Colors.red[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filteredExpenses = selectedCategory == null
                            ? expenses
                            : expenses.where((e) => e.category == selectedCategory).toList();

                        return ListView.builder(
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            final isIncome = expense.type == TransactionType.income;
                            return FadeInLeft(
                              delay: Duration(milliseconds: 100 * index),
                              child: Dismissible(
                                key: Key(expense.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    onLongPress: () async {
                                      final updatedExpense = await context.push<Expense>(
                                        '/edit',
                                        extra: expense,
                                      );
                                      if (updatedExpense != null && context.mounted) {
                                        context.read<ExpenseBloc>().add(UpdateExpenseEvent(updatedExpense));
                                      }
                                    },
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: _getCategoryColor(expense.category).withValues(alpha: 0.2),
                                          child: Icon(
                                            _getIcon(expense.category),
                                            color: _getCategoryColor(expense.category),
                                            size: 28,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: isIncome ? Colors.green : Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: Icon(
                                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(expense.title, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Text(
                                      DateFormat('dd/MM/yyyy').format(expense.date),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Text(
                                      '${isIncome ? '+' : '-'}${NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: '',
                                        decimalDigits: 0,
                                      ).format(expense.amount)}₫',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 17,
                                        color: isIncome ? Colors.green[700] : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        Text(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: 'VNĐ',
            decimalDigits: 0,
          ).format(amount),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'đồ ăn': return Icons.restaurant;
      case 'đi lại': return Icons.directions_bus;
      case 'mua sắm': return Icons.shopping_bag;
      case 'hóa đơn': return Icons.receipt_long;
      case 'lương': return Icons.payments;
      case 'quà tặng': return Icons.card_giftcard;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'đồ ăn': return Colors.orange;
      case 'đi lại': return Colors.blue;
      case 'mua sắm': return Colors.purple;
      case 'hóa đơn': return Colors.red;
      case 'lương': return Colors.green;
      case 'quà tặng': return Colors.pink;
      default: return Colors.blueGrey;
    }
  }
}
