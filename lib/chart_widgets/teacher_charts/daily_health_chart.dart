import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:stem_2022/models/group.dart';

class DailyHealthChart extends StatelessWidget {
  final List<HealthDataPoint> data;

  const DailyHealthChart({super.key, required this.data});

  String? _weekdayIntToString(int weekday) {
    switch (weekday) {
      case 1:
        return "MON";
      case 2:
        return "TUE";
      case 3:
        return "WED";
      case 4:
        return "THU";
      case 5:
        return "FRI";
      case 6:
        return "SAT";
      case 7:
        return "SUN";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: min(7, data.length).toDouble(),
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
                if (value >= data.length) return const Text("");
                final date = data[value.toInt()].timestamp.toDate();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _weekdayIntToString(date.weekday) ?? "DAY",
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.greenAccent,
            spots: data
                .asMap()
                .map(
                  (idx, dataPoint) => MapEntry(
                    idx,
                    FlSpot(idx.toDouble(), dataPoint.healthyPercent * 100),
                  ),
                )
                .values
                .toList(),
          ),
        ],
      ),
    );
  }
}
