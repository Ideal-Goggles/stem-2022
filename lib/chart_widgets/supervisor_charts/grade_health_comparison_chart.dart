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
        barGroups: indexedGrades
            .asMap()
            .map((idx, grade) {
              final totalGradeHealth =
                  gradeWiseData[grade]!.reduce((a, b) => a + b);
              final avgGradeHealth =
                  totalGradeHealth / gradeWiseData[grade]!.length;

              return MapEntry(
                idx,
                BarChartGroupData(x: idx, barRods: [
                  BarChartRodData(
                    toY: avgGradeHealth,
                    borderRadius: BorderRadius.zero,
                    width: 14,
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
