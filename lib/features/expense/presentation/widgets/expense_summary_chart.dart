import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import 'package:collection/collection.dart';

class ExpenseSummaryChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final groupedData = groupBy(expenses, (Expense e) => e.category);
    final sections = groupedData.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, item) => sum + item.amount);
      return PieChartSectionData(
        value: total,
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        color: _getCategoryColor(entry.key),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
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
      default: return Colors.grey;
    }
  }
}
