import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GradeHealthComparisonChart extends StatelessWidget {
  final Map<String, List<double>> gradeWiseData;

  const GradeHealthComparisonChart({super.key, required this.gradeWiseData});

  @override
  Widget build(BuildContext context) {
    List<String> indexedGrades = [];

    for (final grade in gradeWiseData.keys) {
      indexedGrades.add(grade);
    }

    // Sort the indexed grades
    indexedGrades.sort();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        borderData: FlBorderData(
          border: Border.all(color: Colors.blueGrey, width: 0.5),
        ),
        gridData: FlGridData(verticalInterval: 1),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            drawBehindEverything: true,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "${value.toInt()}%",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            drawBehindEverything: true,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value >= gradeWiseData.length) return const Text("");

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    indexedGrades[value.toInt()],
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsPrecision(4),
                const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        barGroups: indexedGrades
            .asMap()
            .map((idx, grade) {
              final totalGradeHealth =
                  gradeWiseData[grade]!.reduce((a, b) => a + b);
              final avgGradeHealth =
                  totalGradeHealth * 100 / gradeWiseData[grade]!.length;

              return MapEntry(
                idx,
                BarChartGroupData(x: idx, barRods: [
                  BarChartRodData(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    toY: avgGradeHealth,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    width: 30,
                  )
                ]),
              );
            })
            .values
            .toList(),
      ),
    );
  }
}
