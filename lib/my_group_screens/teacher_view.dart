import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/misc.dart';

import 'package:stem_2022/chart_widgets/teacher_charts/daily_health_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/daily_wastage_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/monthly_health_chart.dart';
import 'package:stem_2022/chart_widgets/teacher_charts/monthly_wastage_chart.dart';

import 'package:stem_2022/my_group_screens/day_wise_health_data.dart';
import 'package:stem_2022/my_group_screens/group_announcements.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

class AddDataAlertDialog extends StatefulWidget {
  const AddDataAlertDialog({super.key});

  @override
  State<AddDataAlertDialog> createState() => _AddDataAlertDialogState();
}

class _AddDataAlertDialogState extends State<AddDataAlertDialog> {
  final _formKey = GlobalKey<FormState>();

  double foodWastage = 0;
  int healthyStudents = 0;
  int totalStudents = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text("Add Class Data"),
      content: SizedBox(
        width: 300,
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
                onSaved: (newValue) => healthyStudents = int.parse(newValue!),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Students with Healthy Food"),
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
                onSaved: (newValue) => totalStudents = int.parse(newValue!),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Total Number of Students"),
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
                Pair(
                  first: foodWastage,
                  second: healthyStudents / totalStudents,
                ),
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
  final Group group;
  final SubGroup subGroup;
  final bool writeable;

  const TeacherView({
    super.key,
    required this.group,
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
            groupId: group.id,
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
        StreamBuilder(
          stream: db.streamAppUser(subGroup.classTeacher),
          builder: (context, snapshot) {
            return Text(
              "Class Teacher: ${snapshot.data?.displayName ?? "Unknown"}",
              style: _bodyTextStyle,
            );
          },
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
          const SizedBox(height: 10),
        ],

        // Day-wise data button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: MaterialButton(
            height: 42,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayWiseHealthDataScreen(
                  group: group,
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

        const SizedBox(height: 10),

        // Section Announcements Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: MaterialButton(
            height: 42,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupAnnouncementsScreen(
                  group: group,
                  section: subGroup.section,
                  writeable: false,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Theme.of(context).colorScheme.primary,
            child: const Text("View Section Announcements"),
          ),
        ),

        const SizedBox(height: 15),

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
            stream: db.streamWastageData(group.id, subGroup.id),
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
            stream: db.streamHealthData(group.id, subGroup.id),
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
              group.id,
              subGroup.id,
              yearStart: group.academicYearStart.toDate(),
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
            "Wastage Report (Current Academic Year)",
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
              group.id,
              subGroup.id,
              yearStart: group.academicYearStart.toDate(),
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
            "Health Report (Current Academic Year)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),

        _divider,
      ],
    );
  }
}
