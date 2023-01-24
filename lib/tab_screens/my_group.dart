import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/my_group_screens/teacher_view.dart';
import 'package:stem_2022/my_group_screens/supervisor_view.dart';

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
            return PrincipalView(
              groupId: group.id,
              sections: group.sections,
            );
          }

          if (group.supervisors.containsKey(appUser.id)) {
            return SupervisorView(
              section: group.supervisors[appUser.id]!,
              groupId: group.id,
            );
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

class PrincipalView extends StatefulWidget {
  final String groupId;
  final List sections;
  const PrincipalView(
      {super.key, required this.groupId, required this.sections});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  late final Map<String, double> _gradeWastage;
  late final Map<String, List<double>> _gradeHealth;
  late final Map<String, double> _subGroupWastage;
  late final Map<String, List<double>> _subGroupHealth;

  late final Map<String, double> _gradeWastageForYear;
  late final Map<String, List<double>> _gradeHealthForYear;
  late final Map<String, double> _subGroupWastageForYear;
  late final Map<String, List<double>> _subGroupHealthForYear;

  late final Map<String, Map<String, List<double>>> sectionsData;

  bool _loading = true;

  TextStyle get _bodyTextStyle => TextStyle(
        color: Colors.grey.shade300,
        fontSize: 15,
      );
  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  void initState() {
    final db = Provider.of<DatabaseService>(context, listen: false);

    db.getSectionSubGroups(widget.groupId, "Senior").then(
      (subGroups) async {
        Map<String, double> gradeWastage = {};
        Map<String, List<double>> gradeHealth = {};
        Map<String, double> subGroupWastage = {};
        Map<String, List<double>> subGroupHealth = {};

        Map<String, double> gradeWastageForYear = {};
        Map<String, List<double>> gradeHealthForYear = {};
        Map<String, double> subGroupWastageForYear = {};
        Map<String, List<double>> subGroupHealthForYear = {};

        for (final subGroup in subGroups) {
          final subGroupGrade = subGroup.id;

          // Fetch data
          final wastageFuture = db.getWastageData(widget.groupId, subGroup.id);
          final wastageForYearFuture = db.getWastageDataForYear(
            widget.groupId,
            subGroup.id,
            year: DateTime.now().year,
          );

          final healthFuture = db.getHealthData(widget.groupId, subGroup.id);
          final healthForYearFuture = db.getHealthDataForYear(
            widget.groupId,
            subGroup.id,
            year: DateTime.now().year,
          );

          // Process wastage data
          for (final wastage in await wastageFuture) {
            gradeWastage.update(
              subGroupGrade,
              (w) => w + wastage.totalWastage,
              ifAbsent: () => wastage.totalWastage,
            );
            subGroupWastage.update(
              subGroup.id,
              (w) => w + wastage.totalWastage,
              ifAbsent: () => wastage.totalWastage,
            );
          }

          // Process wastage for year data
          for (final wastage in await wastageForYearFuture) {
            gradeWastageForYear.update(
              subGroupGrade,
              (w) => w + wastage.totalWastage,
              ifAbsent: () => wastage.totalWastage,
            );
            subGroupWastageForYear.update(
              subGroup.id,
              (w) => w + wastage.totalWastage,
              ifAbsent: () => wastage.totalWastage,
            );
          }

          // Process health data
          for (final health in await healthFuture) {
            gradeHealth.update(
              subGroupGrade,
              (h) => [...h, health.healthyPercent],
              ifAbsent: () => [health.healthyPercent],
            );
            subGroupHealth.update(
              subGroup.id,
              (h) => [...h, health.healthyPercent],
              ifAbsent: () => [health.healthyPercent],
            );
          }
          for (final health in await healthForYearFuture) {
            gradeHealthForYear.update(
              subGroupGrade,
              (h) => [...h, health.healthyPercent],
              ifAbsent: () => [health.healthyPercent],
            );
            subGroupHealthForYear.update(
              subGroup.id,
              (h) => [...h, health.healthyPercent],
              ifAbsent: () => [health.healthyPercent],
            );
          }
        }

        // Process health for year data

        // Update state after all data has been processed
        setState(
          () {
            _gradeWastage = gradeWastage;
            _gradeHealth = gradeHealth;
            _subGroupWastage = subGroupWastage;
            _subGroupHealth = subGroupHealth;

            _gradeWastageForYear = gradeWastageForYear;
            _gradeHealthForYear = gradeHealthForYear;

            _loading = false;
          },
        );
        print(gradeHealth);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        for (final section in widget.sections)
          ExpansionTile(
            title: Text("$section"),
            childrenPadding: const EdgeInsets.all(15),
            children: [
              SizedBox(
                height: 205,
              )
            ],
          )
      ],
    );
  }
}
