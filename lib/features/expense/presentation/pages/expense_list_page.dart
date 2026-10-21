import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/utils/expense_calculations.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_balance_card.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_item_card.dart';
import '../widgets/expense_empty_view.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _filterType;
  DateTime? _selectedMonth;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filterType = null;
      _selectedMonth = null;
      _selectedCategory = null;
    });
  }

  void _openFilterSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ExpenseFilterSheet(
        initialFilterType: _filterType,
        initialSelectedMonth: _selectedMonth,
        initialSelectedCategory: _selectedCategory,
        availableCategories: categories,
        onApplyFilters: ({filterType, selectedMonth, selectedCategory}) {
          setState(() {
            _filterType = filterType;
            _selectedMonth = selectedMonth;
            _selectedCategory = selectedCategory;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter =
        _filterType != null || _selectedMonth != null || _selectedCategory != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Sổ chi tiêu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Cài đặt thông báo',
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
            onPressed: () {
              context.push('/notification-settings');
            },
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('HỦY')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('ĐĂNG XUẤT'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await Supabase.instance.client.auth.signOut();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            final expenses = state.expenses;
            final totalIncome = ExpenseCalculations.totalIncome(expenses);
            final totalExpense = ExpenseCalculations.totalExpense(expenses);
            final balance = ExpenseCalculations.balance(expenses);

            final filteredExpenses = ExpenseCalculations.filterExpenses(
              expenses: expenses,
              searchQuery: _searchQuery,
              selectedCategory: _selectedCategory,
              filterType: _filterType,
              selectedMonth: _selectedMonth,
            );

            final availableCategories = expenses
                .map((e) => e.categoryName)
                .whereType<String>()
                .toSet()
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ExpenseBloc>().add(LoadExpenses());
              },
              child: Column(
                children: [
                  // 1. Thẻ tổng quan số dư (Đẩy danh sách chi tiêu lên ngay bên dưới)
                  ExpenseBalanceCard(
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                    balance: balance,
                  ),

                  // 2. Thanh tìm kiếm và nút Bộ lọc
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm giao dịch...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Badge(
                          isLabelVisible: hasActiveFilter,
                          label: const Text('1'),
                          backgroundColor: Colors.deepPurple,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: hasActiveFilter ? Colors.deepPurple : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.filter_list,
                                color: hasActiveFilter ? Colors.white : Colors.deepPurple,
                                size: 22,
                              ),
                              onPressed: () => _openFilterSheet(availableCategories),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Header danh sách & số lượng
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách giao dịch (${filteredExpenses.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (hasActiveFilter || _searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: _resetFilters,
                            child: const Text(
                              'Xóa bộ lọc',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 4. Danh sách giao dịch
                  Expanded(
                    child: filteredExpenses.isEmpty
                        ? ExpenseEmptyView(
                            isFiltered: hasActiveFilter || _searchQuery.isNotEmpty,
                            onResetFilters: _resetFilters,
                            onAddExpense: () async {
                              final newExpense = await context.push<Expense>('/add');
                              if (newExpense != null && context.mounted) {
                                context.read<ExpenseBloc>().add(AddExpenseEvent(newExpense));
                              }
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = filteredExpenses[index];
                              return ExpenseItemCard(
                                expense: expense,
                                index: index,
                                onTap: () async {
                                  final updatedExpense = await context.push<Expense>(
                                    '/edit',
                                    extra: expense,
                                  );
                                  if (updatedExpense != null && context.mounted) {
                                    context.read<ExpenseBloc>().add(UpdateExpenseEvent(updatedExpense));
                                  }
                                },
                                onDelete: () {
                                  context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã xóa "${expense.title}"'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          } else if (state is ExpenseError) {
            return Center(
              child: Text(
                'Lỗi: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}