import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample1 extends StatefulWidget {
  const PieChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State<PieChartSample1> {
  int touchedIndex = -1;
  final List<SectionData> sectionsData = [
    SectionData(color: Colors.blue, text: 'One', value: 25, radius: 80, offset: .55),
    SectionData(color: Colors.yellow, text: 'Two', value: 25, radius: 65, offset: .55),
    SectionData(color: Colors.pink, text: 'Three', value: 25, radius: 60, offset: .6),
    SectionData(color: Colors.green, text: 'Four', value: 25, radius: 70, offset: .55),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 28,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(sectionsData.length, (index) {
              if (touchedIndex != -1 && touchedIndex != index) {
                return const SizedBox.shrink();
              }

              final data = sectionsData[index];
              return Indicator(
                color: data.color,
                text: data.text,
                isSquare: false,
                size: touchedIndex == index ? 18 : 16,
                textColor: touchedIndex == index
                    ? Colors.black
                    : Colors.grey,
              );
            }),
          ),
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      sectionsData.length,
      (i) {
        final isTouched = i == touchedIndex;
        final data = sectionsData[i];

        return PieChartSectionData(
          color: data.color,
          value: data.value,
          title: '',
          radius: data.radius,
          titlePositionPercentageOffset: data.offset,
          borderSide: isTouched
              ? const BorderSide(color: Colors.white, width: 6)
              : BorderSide(color: Colors.white.withValues(alpha: 0)),
        );
      },
    );
  }
}

// Widget Indicator đơn giản (nếu bạn chưa có file indicator.dart)
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}

class SectionData {
  final Color color;
  final String text;
  final double value;
  final double radius;
  final double offset;

  SectionData({
    required this.color,
    required this.text,
    required this.value,
    required this.radius,
    required this.offset,
  });
}
