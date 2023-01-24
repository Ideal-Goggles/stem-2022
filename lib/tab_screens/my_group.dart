import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/misc.dart';
import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/chart_widgets/teacher_charts/daily_health_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/daily_wastage_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/monthly_wastage_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/monthly_health_chart.dart';

import 'package:stem_2022/chart_widgets/supervisor_charts/grade_wastage_comparison_chart.dart';
import 'package:stem_2022/chart_widgets/supervisor_charts/grade_health_comparison_chart.dart';

import 'package:stem_2022/my_group_screens/day_wise_health_data.dart';
import 'package:stem_2022/my_group_screens/section_subgroup_list.dart';

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

class AddDataAlertDialog extends StatefulWidget {
  const AddDataAlertDialog({super.key});

  @override
  State<AddDataAlertDialog> createState() => _AddDataAlertDialogState();
}

class _AddDataAlertDialogState extends State<AddDataAlertDialog> {
  final _formKey = GlobalKey<FormState>();

  double foodWastage = 0;
  double healthyPercent = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text("Add Class Data"),
      content: SizedBox(
        width: 300,
        height: 180,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                onSaved: (newValue) => foodWastage = double.parse(newValue!),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Food Wastage (grams)"),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  }
                  return "Please enter a number";
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                onSaved: (newValue) => healthyPercent = double.parse(newValue!),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("% of Students with Healthy Food"),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final numValue = double.tryParse(value);

                    if (numValue == null) {
                      return "Enter a valid number";
                    } else if (numValue < 0 || numValue > 100) {
                      return "Percentage must be between 0% and 100%";
                    }
                    return null;
                  }
                  return "Please enter a number";
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              Navigator.pop(
                context,
                Pair(first: foodWastage, second: healthyPercent / 100),
              );
            }
          },
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text("Submit"),
        ),
      ],
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

  final _dataTimeGap = const Duration(hours: 20);

  TextStyle get _bodyTextStyle => TextStyle(
        color: Colors.grey.shade300,
        fontSize: 15,
      );
  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  Future<void> showAddDataDialog(BuildContext context) async {
    if (!writeable) return;

    if (subGroup.lastUpdated != null) {
      final now = DateTime.now();
      final timeDiff = now.difference(subGroup.lastUpdated!.toDate());

      if (timeDiff <= _dataTimeGap) {
        final nextDataTime = subGroup.lastUpdated!.toDate().add(_dataTimeGap);
        final timeTillNext = nextDataTime.difference(now);

        String timeString;

        if (timeTillNext.inSeconds > 60) {
          final timeStringSplit = timeTillNext.toString().split(":");
          timeString = "${timeStringSplit[0]}:${timeStringSplit[1]} hour(s)";
        } else {
          timeString = "${timeTillNext.inSeconds} second(s)";
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "You have already added data today, come back in $timeString.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        return;
      }
    }

    showDialog<Pair?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AddDataAlertDialog();
      },
    ).then<bool>((dataPair) {
      if (dataPair == null) return false;
      final db = Provider.of<DatabaseService>(context, listen: false);

      return db
          .addSubGroupData(
            groupId: groupId,
            subGroupId: subGroup.id,
            totalWastage: dataPair.first,
            healthyPercent: dataPair.second,
          )
          .then((_) => true);
    }).then((value) {
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully added new data!",
            textAlign: TextAlign.center,
          ),
        ));
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString(), textAlign: TextAlign.center),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    });
  }

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
        const SizedBox(height: 15),

        // Add Data Button
        if (writeable) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: MaterialButton(
              height: 42,
              onPressed: () => showAddDataDialog(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: Theme.of(context).colorScheme.primary,
              child: const Text("Add Data"),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Daily Wastage Report
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: StreamBuilder(
            stream: db.streamWastageData(groupId, subGroup.id),
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
            "Wastage Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 20),

        // Daily Health Report
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: StreamBuilder(
            stream: db.streamHealthData(groupId, subGroup.id),
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
            "Health Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: MaterialButton(
            height: 42,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayWiseHealthDataScreen(
                  groupId: groupId,
                  subGroupId: subGroup.id,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Theme.of(context).colorScheme.primary,
            child: const Text("View Day-wise Health Data"),
          ),
        ),

        const SizedBox(height: 20),
        _divider,
        Text(
          "Monthly Report of ${subGroup.id}",
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),

        // Monthly Wastage Report
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: StreamBuilder(
            stream: db.streamWastageDataForYear(
              groupId,
              subGroup.id,
              year: DateTime.now().year,
            ),
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

              return MonthlyWastageChart(data: snapshot.data!);
            },
          ),
        ),
        const Center(
          child: Text(
            "Wastage Report (This Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 20),

        // Monthly Health Report
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: StreamBuilder(
            stream: db.streamHealthDataForYear(
              groupId,
              subGroup.id,
              year: DateTime.now().year,
            ),
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

              return MonthlyHealthChart(data: snapshot.data!);
            },
          ),
        ),
        const Center(
          child: Text(
            "Health Report (This Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),

        _divider,
      ],
    );
  }
}

class SupervisorView extends StatefulWidget {
  final String section;
  final String groupId;

  const SupervisorView({
    super.key,
    required this.section,
    required this.groupId,
  });

  @override
  State<SupervisorView> createState() => _SupervisorViewState();
}

class _SupervisorViewState extends State<SupervisorView> {
  late final Map<String, double> _gradeWastage;
  late final Map<String, List<double>> _gradeHealth;
  late final Map<String, double> _subGroupWastage;
  late final Map<String, List<double>> _subGroupHealth;

  late final Map<String, double> _gradeWastageForYear;
  late final Map<String, List<double>> _gradeHealthForYear;
  late final Map<String, double> _subGroupWastageForYear;
  late final Map<String, List<double>> _subGroupHealthForYear;

  bool _loading = true;

  TextStyle get _bodyTextStyle => TextStyle(
        color: Colors.grey.shade300,
        fontSize: 15,
      );
  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  void initState() {
    final db = Provider.of<DatabaseService>(context, listen: false);

    db.getSectionSubGroups(widget.groupId, widget.section).then(
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
          final subGroupGrade =
              subGroup.id.substring(0, subGroup.id.length - 2);

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
        setState(() {
          _gradeWastage = gradeWastage;
          _gradeHealth = gradeHealth;
          _subGroupWastage = subGroupWastage;
          _subGroupHealth = subGroupHealth;

          _gradeWastageForYear = gradeWastageForYear;
          _gradeHealthForYear = gradeHealthForYear;
          _subGroupWastageForYear = subGroupWastageForYear;
          _subGroupHealthForYear = subGroupHealthForYear;

          _loading = false;
        });
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    //Wastage
    final double totalSectionWastage =
        _gradeWastage.values.reduce((a, b) => a + b);
    final double totalSectionWastageForYear =
        _gradeWastageForYear.values.reduce((a, b) => a + b);

    //Health
    double totalSectionHealth = 0;
    int totalSectionHealthEntries = 0;
    double totalSectionHealthForYear = 0;
    int totalSectionHealthEntriesForYear = 0;

    _gradeHealth.forEach(
      (grade, health) {
        // ignore: avoid_function_literals_in_foreach_calls
        health.forEach((h) => totalSectionHealth += h);
        totalSectionHealthEntries += health.length;
      },
    );

    _gradeHealthForYear.forEach(
      (grade, health) {
        // ignore: avoid_function_literals_in_foreach_calls
        health.forEach((h) => totalSectionHealthForYear += h);
        totalSectionHealthEntriesForYear += health.length;
      },
    );

    double avgSectionHealth =
        (totalSectionHealth * 100 / totalSectionHealthEntries).roundToDouble();
    double avgSectionHealthForYear =
        (totalSectionHealthForYear * 100 / totalSectionHealthEntriesForYear)
            .roundToDouble();

    return ListView(
      padding: const EdgeInsets.only(bottom: 75),
      children: [
        _divider,
        Text(
          "Monthly ${widget.section} Section Report",
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          "Total ${widget.section} Section Wastage: $totalSectionWastage grams",
          style: _bodyTextStyle,
        ),
        Text(
          "Average ${widget.section} Section Health: $avgSectionHealth %",
          style: _bodyTextStyle,
        ),
        const SizedBox(height: 15),

        // Class-wise data button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: MaterialButton(
            height: 42,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SectionSubGroupListScreen(
                  groupId: widget.groupId,
                  section: widget.section,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Theme.of(context).colorScheme.primary,
            child: const Text("View Class-wise Data"),
          ),
        ),

        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: GradeWastageComparisonChart(gradeWiseData: _gradeWastage),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Grade-wise Wastage Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: GradeHealthComparisonChart(gradeWiseData: _gradeHealth),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Grade-wise Health Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 25),

        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: GradeWastageComparisonChart(gradeWiseData: _subGroupWastage),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Class-wise Wastage Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: GradeHealthComparisonChart(gradeWiseData: _subGroupHealth),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Class-wise Health Report (Previous Week)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 10),
        _divider,

        Text(
          "Yearly ${widget.section} Section Report",
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          "Total ${widget.section} Section Wastage (for year): $totalSectionWastageForYear grams",
          style: _bodyTextStyle,
        ),
        Text(
          "Average ${widget.section} Section Health (for year): $avgSectionHealthForYear %",
          style: _bodyTextStyle,
        ),
        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child:
              GradeWastageComparisonChart(gradeWiseData: _gradeWastageForYear),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Grade-wise Wastage Report (Past Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: GradeHealthComparisonChart(gradeWiseData: _gradeHealthForYear),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Grade-wise Health Report (Past Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 25),

        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: GradeWastageComparisonChart(
              gradeWiseData: _subGroupWastageForYear),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Class-wise Wastage Report (Previous Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 500,
          padding: const EdgeInsets.only(
            top: 30,
            right: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child:
              GradeHealthComparisonChart(gradeWiseData: _subGroupHealthForYear),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Class-wise Health Report (Previous Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class PrincipalView extends StatefulWidget {
  final String groupId;
  const PrincipalView({super.key, required this.groupId});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Principal View"));
  }
}
