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

  Widget dailyWastageReportChart(List<WastageDataPoint> wastageData) {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(left: 6, bottom: 6, right: 10, top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromRGBO(17, 40, 106, 1),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: min(7, wastageData.length).toDouble(),
          minY: 0,
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

                  Widget text(String day) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        day,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    );
                  }

                  final date = wastageData[value.toInt()].timestamp.toDate();

                  switch (date.weekday) {
                    case 1:
                      return text("MON");
                    case 2:
                      return text("TUE");
                    case 3:
                      return text("WED");
                    case 4:
                      return text("THU");
                    case 5:
                      return text("FRI");
                    case 6:
                      return text("SAT");
                    case 7:
                      return text("SUN");
                    default:
                      return text("DAY");
                  }
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
                      FlSpot(idx.toDouble(), dataPoint.totalWastage.toDouble()),
                    ),
                  )
                  .values
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _divider,
          const Text("Daily Report", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          StreamBuilder(
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

                return dailyWastageReportChart(snapshot.data!);
              }),
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
