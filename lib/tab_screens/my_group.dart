import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/chart_widgets/daily_health_chart.dart';
import 'package:stem_2022/chart_widgets/daily_wastage_chart.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MultiProvider(
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
            subGroup: subGroup!,
            writeable: subGroup.classTeacher == appUser.id,
          );
        },
      ),
    );
  }
}

class TeacherView extends StatelessWidget {
  final String groupId;
  final SubGroup subGroup;
  final bool writeable;

  const TeacherView({
    super.key,
    required this.groupId,
    required this.subGroup,
    required this.writeable,
  });

  TextStyle get _bodyTextStyle => TextStyle(
        color: Colors.grey.shade300,
        fontSize: 15,
      );
  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 75),
      children: [
        _divider,
        Text(
          "Daily Report of ${subGroup.id}",
          style: const TextStyle(fontSize: 20),
        ),
        Text("Total Points: ${subGroup.points} H", style: _bodyTextStyle),

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
            stream: db.streamPreviousWeekWastageData(groupId, subGroup.id),
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

              return DailyWastageChart(data: snapshot.data!);
            },
          ),
        ),
        const Center(
          child: Text(
            "Wastage Report",
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
            stream: db.streamPreviousWeekHealthData(groupId, subGroup.id),
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

              return DailyHealthChart(data: snapshot.data!);
            },
          ),
        ),
        const Center(
          child: Text(
            "Health Report",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
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
