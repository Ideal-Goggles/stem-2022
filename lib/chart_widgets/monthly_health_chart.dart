import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:stem_2022/models/group.dart';

class MonthlyHealthChart extends StatelessWidget {
  final List<HealthDataPoint> data;

  const MonthlyHealthChart({super.key, required this.data});

  /// January = 0, December = 11
  String? _monthIntToString(int month) {
    switch (month + 1) {
      case DateTime.january:
        return "JAN";
      case DateTime.february:
        return "FEB";
      case DateTime.march:
        return "MAR";
      case DateTime.april:
        return "APR";
      case DateTime.may:
        return "MAY";
      case DateTime.june:
        return "JUN";
      case DateTime.july:
        return "JUL";
      case DateTime.august:
        return "AUG";
      case DateTime.september:
        return "SEP";
      case DateTime.october:
        return "OCT";
      case DateTime.november:
        return "NOV";
      case DateTime.december:
        return "DEC";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthWiseData = List<double>.filled(12, 0);
    final monthDataPointCount = List<double>.filled(12, 0);

    for (final dataPoint in data) {
      final timestampDate = dataPoint.timestamp.toDate();
      final zeroMonth = timestampDate.month - 1;

      monthWiseData[zeroMonth] += dataPoint.healthyPercent;
      monthDataPointCount[zeroMonth]++;
    }

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
                if (value >= monthWiseData.length) return const Text("");

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _monthIntToString(value.toInt()) ?? "?",
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: monthWiseData
            .asMap()
            .map(
              (idx, healthyPercent) => MapEntry(
                idx,
                BarChartGroupData(x: idx, barRods: [
                  BarChartRodData(
                    toY: (healthyPercent / monthDataPointCount[idx]) * 100,
                    borderRadius: BorderRadius.zero,
                    width: 14,
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
