import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import 'package:collection/collection.dart';

class ExpenseSummaryChart extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String?) onCategorySelected;

  const ExpenseSummaryChart({
    super.key,
    required this.expenses,
    required this.onCategorySelected,
  });

  @override
  State<ExpenseSummaryChart> createState() => _ExpenseSummaryChartState();
}

class _ExpenseSummaryChartState extends State<ExpenseSummaryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expenseOnly = widget.expenses.where((e) => e.type == TransactionType.expense).toList();
    if (expenseOnly.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Không có dữ liệu chi tiêu', style: TextStyle(color: Colors.white70))),
      );
    }

    final groupedData = groupBy(expenseOnly, (Expense e) => e.category);
    final categories = groupedData.keys.toList();
    
    final sections = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final items = groupedData[category]!;
      final total = items.fold(0.0, (sum, item) => sum + item.amount);
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        value: total,
        title: isTouched ? '${(total / expenseOnly.fold(0.0, (s, i) => s + i.amount) * 100).toStringAsFixed(0)}%' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        color: _getCategoryColor(category),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      widget.onCategorySelected(null);
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (touchedIndex >= 0 && touchedIndex < categories.length) {
                      widget.onCategorySelected(categories[touchedIndex]);
                    } else {
                      widget.onCategorySelected(null);
                    }
                  });
                },
              ),
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              if (touchedIndex != -1 && touchedIndex != index) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _Indicator(
                  color: _getCategoryColor(category),
                  text: category,
                  isSquare: false,
                  size: touchedIndex == index ? 16 : 12,
                  textColor: touchedIndex == index ? Colors.black : Colors.black,
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 12,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: size + 2,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
