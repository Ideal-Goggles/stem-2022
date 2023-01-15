import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

class MyGroupScreen extends StatelessWidget {
  const MyGroupScreen({super.key});

  Widget centerText(String content) {
    return Center(
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final appUser = Provider.of<AppUser?>(context);

    if (appUser == null) {
      return centerText("Log in to view group details");
    }

    if (appUser.groupId == null) {
      return centerText("Join a group to view group details");
    }

    return MultiProvider(
      providers: [
        StreamProvider<Group?>.value(
          value: db.streamGroup(appUser.groupId!),
          initialData: null,
        ),
        StreamProvider<SubGroup?>.value(
          value: appUser.subGroupId == null
              ? null
              : db.streamSubGroup(appUser.groupId!, appUser.subGroupId!),
          initialData: null,
        ),
      ],
      builder: (context, child) {
        final group = Provider.of<Group?>(context);
        final subGroup = Provider.of<SubGroup?>(context);

        if (group == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (group.admin == appUser.id) {
          return const PrincipalView();
        }

        if (group.supervisors.containsKey(appUser.id)) {
          return SupervisorView(section: group.supervisors[appUser.id]!);
        }

        if (appUser.subGroupId == null) {
          return centerText("Join a class to view class details");
        }

        return TeacherView(
          groupId: group.id,
          subGroupId: subGroup!.id,
          writeable: subGroup.classTeacher == appUser.id,
        );
      },
    );
  }
}

String? weekdayIntToString(int weekday) {
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

LineChart _dailyWastageReportChart(List<WastageDataPoint> wastageData) {
  return LineChart(
    LineChartData(
      minX: 0,
      maxX: min(7, wastageData.length).toDouble(),
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
              final v = value >= 1000
                  ? "${value ~/ 1000} K"
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
              if (value >= wastageData.length) return const Text("");
              final date = wastageData[value.toInt()].timestamp.toDate();

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  weekdayIntToString(date.weekday) ?? "DAY",
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
          spots: wastageData
              .asMap()
              .map(
                (idx, dataPoint) => MapEntry(
                  idx,
                  FlSpot(idx.toDouble(), dataPoint.totalWastage),
                ),
              )
              .values
              .toList(),
        ),
      ],
    ),
  );
}

LineChart _dailyHealthReportChart(List<HealthDataPoint> healthData) {
  return LineChart(
    LineChartData(
      minX: 0,
      maxX: min(7, healthData.length).toDouble(),
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
              if (value >= healthData.length) return const Text("");
              final date = healthData[value.toInt()].timestamp.toDate();

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  weekdayIntToString(date.weekday) ?? "DAY",
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
          spots: healthData
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

class TeacherView extends StatelessWidget {
  final String groupId;
  final String subGroupId;
  final bool writeable;

  const TeacherView({
    super.key,
    required this.groupId,
    required this.subGroupId,
    required this.writeable,
  });

  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          _divider,
          const Text("Daily Report", style: TextStyle(fontSize: 20)),

          // Wastage Report
          const SizedBox(height: 15),
          Container(
            height: 280,
            padding: const EdgeInsets.only(
              left: 6,
              bottom: 6,
              right: 10,
              top: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromRGBO(17, 40, 106, 1),
            ),
            child: StreamBuilder(
              stream: db.streamPreviousWeekWastageData(groupId, subGroupId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _dailyWastageReportChart(snapshot.data!);
              },
            ),
          ),
          const Center(
            child: Text(
              "Wastage Report",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          // Health Report
          const SizedBox(height: 20),
          Container(
            height: 280,
            padding: const EdgeInsets.only(
              left: 6,
              bottom: 6,
              right: 10,
              top: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromRGBO(17, 40, 106, 1),
            ),
            child: StreamBuilder(
              stream: db.streamPreviousWeekHealthData(groupId, subGroupId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _dailyHealthReportChart(snapshot.data!);
              },
            ),
          ),
          const Center(
            child: Text(
              "Health Report",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class SupervisorView extends StatelessWidget {
  final String section;

  const SupervisorView({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("$section Supervisor View"));
  }
}

class PrincipalView extends StatelessWidget {
  const PrincipalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Principal View"));
  }
}
