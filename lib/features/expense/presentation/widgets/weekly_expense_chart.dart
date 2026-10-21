import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/utils/expense_calculations.dart';

enum ChartDisplayMode { combined, bar, line }

class WeeklyExpenseChart extends StatefulWidget {
  final List<DailyExpensePoint> dailyPoints;

  const WeeklyExpenseChart({
    super.key,
    required this.dailyPoints,
  });

  @override
  State<WeeklyExpenseChart> createState() => _WeeklyExpenseChartState();
}

class _WeeklyExpenseChartState extends State<WeeklyExpenseChart> {
  ChartDisplayMode _mode = ChartDisplayMode.combined;
  int? _touchedIndex;

  final currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final points = widget.dailyPoints;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tính toán các chỉ số
    double maxAmount = 0;
    double total7Days = 0;
    DailyExpensePoint? maxDay;

    for (final p in points) {
      total7Days += p.expenseAmount;
      if (p.expenseAmount > maxAmount) {
        maxAmount = p.expenseAmount;
        maxDay = p;
      }
    }

    final avgDaily = total7Days / points.length;
    final chartMaxY = maxAmount == 0 ? 100000.0 : maxAmount * 1.25;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Card(
        elevation: 4,
        shadowColor: Colors.deepPurple.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.deepPurple.shade50.withValues(alpha: 0.4),
              ],
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Mode switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.show_chart,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiêu 7 ngày gần nhất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Biểu đồ Cột + Đường xu hướng',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<ChartDisplayMode>(
                    icon: const Icon(Icons.tune, color: Colors.deepPurple, size: 22),
                    tooltip: 'Chế độ hiển thị',
                    onSelected: (mode) => setState(() => _mode = mode),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ChartDisplayMode.combined,
                        child: Text('Kép (Cột + Đường)'),
                      ),
                      const PopupMenuItem(
                        value: ChartDisplayMode.bar,
                        child: Text('Chỉ Biểu đồ Cột'),
                      ),
                      const PopupMenuItem(
                        value: ChartDisplayMode.line,
                        child: Text('Chỉ Biểu đồ Đường'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thống kê nhanh: Tổng chi, Trung bình ngày, Đỉnh điểm
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickMetric('Tổng 7 ngày', total7Days, Colors.deepPurple),
                    Container(height: 30, width: 1, color: Colors.grey.shade300),
                    _buildQuickMetric('TB mỗi ngày', avgDaily, Colors.indigo),
                    Container(height: 30, width: 1, color: Colors.grey.shade300),
                    _buildQuickMetric(
                      'Cao nhất (${maxDay?.dayLabel ?? '-'})',
                      maxAmount,
                      Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vùng hiển thị Biểu đồ (Cột + Đường)
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    // Layer 1: Biểu đồ Cột
                    if (_mode == ChartDisplayMode.combined || _mode == ChartDisplayMode.bar)
                      BarChart(
                        BarChartData(
                          maxY: chartMaxY,
                          minY: 0,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.deepPurple.shade800,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final point = points[group.x.toInt()];
                                return BarTooltipItem(
                                  '${point.fullDateLabel} (${point.dayLabel})\n',
                                  const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: currencyFormat.format(point.expenseAmount),
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            touchCallback: (event, response) {
                              if (response?.spot != null && event.isInterestedForInteractions) {
                                setState(() {
                                  _touchedIndex = response!.spot!.touchedBarGroupIndex;
                                });
                              } else {
                                setState(() {
                                  _touchedIndex = null;
                                });
                              }
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const SizedBox.shrink();
                                  String text;
                                  if (value >= 1000000) {
                                    text = '${(value / 1000000).toStringAsFixed(1)}Tr';
                                  } else if (value >= 1000) {
                                    text = '${(value / 1000).toInt()}k';
                                  } else {
                                    text = value.toInt().toString();
                                  }
                                  return Text(
                                    text,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final point = points[index];
                                  final isTouched = index == _touchedIndex;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      point.dayLabel,
                                      style: TextStyle(
                                        color: isTouched ? Colors.deepPurple : Colors.black87,
                                        fontSize: 11,
                                        fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: chartMaxY / 4,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: points.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final point = entry.value;
                            final isTouched = idx == _touchedIndex;
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: point.expenseAmount,
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: isTouched
                                        ? [Colors.deepPurple, Colors.purpleAccent]
                                        : [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
                                  ),
                                  width: _mode == ChartDisplayMode.combined ? 14 : 20,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: chartMaxY,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                    // Layer 2: Biểu đồ Đường xu hướng (Line Chart)
                    if (_mode == ChartDisplayMode.combined || _mode == ChartDisplayMode.line)
                      IgnorePointer(
                        ignoring: _mode == ChartDisplayMode.combined,
                        child: LineChart(
                          LineChartData(
                            maxY: chartMaxY,
                            minY: 0,
                            lineTouchData: LineTouchData(
                              enabled: _mode == ChartDisplayMode.line,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) => Colors.deepPurple.shade900,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final point = points[spot.spotIndex];
                                    return LineTooltipItem(
                                      '${point.fullDateLabel}: ${currencyFormat.format(spot.y)}',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            gridData: FlGridData(show: _mode == ChartDisplayMode.line),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              show: _mode == ChartDisplayMode.line,
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: _mode == ChartDisplayMode.line,
                                  reservedSize: 42,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: _mode == ChartDisplayMode.line,
                                  getTitlesWidget: (val, _) {
                                    final i = val.toInt();
                                    if (i < 0 || i >= points.length) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(points[i].dayLabel, style: const TextStyle(fontSize: 11)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: points.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value.expenseAmount);
                                }).toList(),
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: Colors.amber.shade700,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                      strokeColor: Colors.amber.shade800,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: _mode == ChartDisplayMode.line,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.amber.withValues(alpha: 0.3),
                                      Colors.amber.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // Chú thích legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_mode == ChartDisplayMode.combined || _mode == ChartDisplayMode.bar) ...[
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    const Text('Chi tiêu thực tế (Cột)', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(width: 16),
                  ],
                  if (_mode == ChartDisplayMode.combined || _mode == ChartDisplayMode.line) ...[
                    Container(width: 14, height: 3, color: Colors.amber.shade700),
                    const SizedBox(width: 6),
                    const Text('Xu hướng dao động (Đường)', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMetric(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
