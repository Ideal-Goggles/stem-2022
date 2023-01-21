import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/models/group.dart';

class DayWiseHealthDataScreen extends StatelessWidget {
  final String groupId;
  final String subGroupId;

  const DayWiseHealthDataScreen({
    super.key,
    required this.groupId,
    required this.subGroupId,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return StreamBuilder(
      stream: db.streamHealthDataForYear(
        groupId,
        subGroupId,
        year: DateTime.now().year,
      ),
      builder: (context, snapshot) {
        final healthData = snapshot.data!.reversed.toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: Text("Day-wise Health Data for $subGroupId")),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: healthData.length,
            itemBuilder: (context, idx) => DataListTile(data: healthData[idx]),
          ),
        );
      },
    );
  }
}

class DataListTile extends StatelessWidget {
  final HealthDataPoint data;

  const DataListTile({super.key, required this.data});

  final _radius = 120.0;

  /// January = 0, December = 11
  String? _monthIntToString(int month) {
    switch (month + 1) {
      case DateTime.january:
        return "January";
      case DateTime.february:
        return "February";
      case DateTime.march:
        return "March";
      case DateTime.april:
        return "April";
      case DateTime.may:
        return "May";
      case DateTime.june:
        return "June";
      case DateTime.july:
        return "July";
      case DateTime.august:
        return "August";
      case DateTime.september:
        return "September";
      case DateTime.october:
        return "October";
      case DateTime.november:
        return "November";
      case DateTime.december:
        return "December";
      default:
        return null;
    }
  }

  String? _weekdayIntToString(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tueday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return null;
    }
  }

  Widget _legend({required String message, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 15,
          height: 15,
          color: color,
        ),
        const SizedBox(width: 10),
        Text(message),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = data.timestamp.toDate();
    final afternoon = timestamp.hour > 12;
    final timestampString =
        "${afternoon ? timestamp.hour - 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, "0")} ${afternoon ? "PM" : "AM"}, ${_weekdayIntToString(timestamp.weekday)} ${timestamp.day} ${_monthIntToString(timestamp.month)} ${timestamp.year}";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey[900],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(timestampString),
          childrenPadding: const EdgeInsets.all(15),
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 0,
                  sectionsSpace: 5,
                  sections: [
                    PieChartSectionData(
                      value: data.healthyPercent,
                      title:
                          "${(data.healthyPercent * 100).toStringAsPrecision(3)}%",
                      radius: _radius,
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: 1 - data.healthyPercent,
                      title:
                          "${(100 - data.healthyPercent * 100).toStringAsPrecision(3)}%",
                      radius: _radius,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _legend(
                    message: "Students with healthy food",
                    color: Colors.green,
                  ),
                  const SizedBox(height: 5),
                  _legend(
                    message: "Students with unhealthy/junk food",
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
