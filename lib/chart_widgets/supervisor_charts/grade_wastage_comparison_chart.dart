import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GradeWastageComparisonChart extends StatelessWidget {
  final Map<String, double> gradeWiseData;
  final double interval;

  const GradeWastageComparisonChart({
    super.key,
    required this.gradeWiseData,
    this.interval = 500,
  });

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
              reservedSize: 50,
              interval: interval,
              getTitlesWidget: (value, meta) {
                final v = value >= 1000
                    ? "${(value / 1000).toStringAsPrecision(2)} K"
                    : value.toInt().toString();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "${v}g",
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
            .map(
              (idx, grade) => MapEntry(
                idx,
                BarChartGroupData(x: idx, barRods: [
                  BarChartRodData(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    toY: gradeWiseData[grade] ?? 0,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    width: 30,
                  )
                ]),
              ),
            )
            .values
            .toList(),
      ),
    );
  }
}
