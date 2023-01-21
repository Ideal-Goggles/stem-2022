import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/models/group.dart';

class SubGroupDataListScreen extends StatelessWidget {
  final String groupId;
  final String subGroupId;

  const SubGroupDataListScreen({
    super.key,
    required this.groupId,
    required this.subGroupId,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return MultiProvider(
      providers: [
        StreamProvider<List<WastageDataPoint>>.value(
          value: db.streamWastageDataForYear(
            groupId,
            subGroupId,
            year: DateTime.now().year,
          ),
          initialData: const [],
        ),
        StreamProvider<List<HealthDataPoint>>.value(
          value: db.streamHealthDataForYear(
            groupId,
            subGroupId,
            year: DateTime.now().year,
          ),
          initialData: const [],
        ),
      ],
      builder: (context, child) {
        List<WastageDataPoint> wastageData =
            Provider.of<List<WastageDataPoint>>(context);
        List<HealthDataPoint> healthData =
            Provider.of<List<HealthDataPoint>>(context);

        if (wastageData.length != healthData.length) {
          throw Exception("Data list lengths do not match!.");
        }

        wastageData = wastageData.reversed.toList(growable: false);
        healthData = healthData.reversed.toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: Text("Day-wise data for $subGroupId")),
          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: wastageData.length,
            itemBuilder: (context, idx) => DataListTile(
                wastage: wastageData[idx], health: healthData[idx]),
          ),
        );
      },
    );
  }
}

class DataListTile extends StatelessWidget {
  final WastageDataPoint wastage;
  final HealthDataPoint health;

  const DataListTile({super.key, required this.wastage, required this.health});

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

  @override
  Widget build(BuildContext context) {
    // return Text("${wastage.totalWastage} and ${health.healthyPercent * 100}%");

    if (wastage.timestamp
            .toDate()
            .difference(health.timestamp.toDate())
            .inSeconds >
        10) {
      throw Exception(
        "Datapoint timestamps do not match!\nDatapoints: wastage=${wastage.id}, health=${health.id}",
      );
    }

    // Interchangeable with health.timestamp
    final timestamp = wastage.timestamp.toDate();
    final afternoon = timestamp.hour > 12;
    final timestampString =
        "${afternoon ? timestamp.hour - 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, "0")} ${afternoon ? "PM" : "AM"}, ${timestamp.day} ${_monthIntToString(timestamp.month)} ${timestamp.year}";

    return ExpansionTile(title: Text(timestampString));
  }
}
