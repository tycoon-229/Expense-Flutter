import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../domain/utils/expense_calculations.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../widgets/weekly_expense_chart.dart';
import '../widgets/expense_summary_chart.dart';

class ExpenseAnalyticsPage extends StatefulWidget {
  const ExpenseAnalyticsPage({super.key});

  @override
  State<ExpenseAnalyticsPage> createState() => _ExpenseAnalyticsPageState();
}

class _ExpenseAnalyticsPageState extends State<ExpenseAnalyticsPage> {
  String? _selectedCategory;

  final currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Thống kê & Báo cáo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            final expenses = state.expenses;
            if (expenses.isEmpty) {
              return Center(
                child: FadeIn(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_chart_outlined, size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có dữ liệu để thống kê',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hãy thêm các giao dịch thu/chi để xem biểu đồ phân tích',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Tính toán số liệu bằng ExpenseCalculations
            final totalIncome = ExpenseCalculations.totalIncome(expenses);
            final totalExpense = ExpenseCalculations.totalExpense(expenses);
            final balance = ExpenseCalculations.balance(expenses);
            final last7Days = ExpenseCalculations.calculateLast7Days(expenses);
            final categorySpendingList = ExpenseCalculations.calculateCategorySpending(expenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thẻ tổng quan tài chính
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng số dư hiện tại',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currencyFormat.format(balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.greenAccent,
                                        child: Icon(Icons.arrow_downward, color: Colors.black87, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Thu nhập', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                currencyFormat.format(totalIncome),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.amberAccent,
                                        child: Icon(Icons.arrow_upward, color: Colors.black87, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Chi tiêu', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                currencyFormat.format(totalExpense),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Biểu đồ Cột + Đường (7 ngày gần nhất)
                  WeeklyExpenseChart(dailyPoints: last7Days),

                  const SizedBox(height: 24),

                  // 3. Biểu đồ tròn: Phân bổ Chi tiêu theo Danh mục
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.deepPurple.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.pie_chart, color: Colors.deepOrange, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phân bổ chi tiêu danh mục',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Chạm vào các phần để lọc',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ExpenseSummaryChart(
                              expenses: expenses,
                              onCategorySelected: (cat) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Bảng xếp hạng chi tiêu theo danh mục
                  if (categorySpendingList.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.deepPurple.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.leaderboard, color: Colors.teal, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Chi tiết chi tiêu từng danh mục',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...categorySpendingList.map((item) {
                                final isSelected = _selectedCategory == null || _selectedCategory == item.categoryName;
                                final catColor = _parseColor(item.colorHex);
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isSelected ? 1.0 : 0.35,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: catColor,
                                              child: Icon(
                                                CategoryIconHelper.getIcon(item.iconKey),
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                item.categoryName,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              currencyFormat.format(item.totalAmount),
                                              style: TextStyle(fontWeight: FontWeight.bold, color: catColor, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(${item.percentage.toStringAsFixed(1)}%)',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: (item.percentage / 100).clamp(0.0, 1.0),
                                            minHeight: 6,
                                            backgroundColor: Colors.grey.shade100,
                                            valueColor: AlwaysStoppedAnimation<Color>(catColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          } else if (state is ExpenseError) {
            return Center(
              child: Text('Lỗi tải thống kê: ${state.message}', style: const TextStyle(color: Colors.red)),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.deepPurple;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.deepPurple;
    }
  }
}
