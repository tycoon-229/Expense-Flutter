import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import 'package:collection/collection.dart';

class ExpenseSummaryChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final expenseOnly = expenses.where((e) => e.type == TransactionType.expense).toList();
    if (expenseOnly.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('Không có dữ liệu chi tiêu')));

    final groupedData = groupBy(expenseOnly, (Expense e) => e.category);
    final sections = groupedData.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, item) => sum + item.amount);
      return PieChartSectionData(
        value: total,
        title: '${entry.key}\n${(total / expenseOnly.fold(0.0, (s, i) => s + i.amount) * 100).toStringAsFixed(0)}%',
        radius: 50, // Giảm từ 60 xuống 50 để có thêm khoảng trống cho text
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        color: _getCategoryColor(entry.key),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30, // Giảm nhẹ center radius
          sectionsSpace: 2,
        ),
      ),
    );
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
