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
        height: 140,
        child: Form(
          key: _formKey,
          child: Column(
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
                  if (value != null) {
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number!";
                    }
                    return null;
                  }
                  return "Please enter a number!";
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
                  label: Text("Percentage of Healthy Students"),
                ),
                validator: (value) {
                  if (value != null) {
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number!";
                    }
                    return null;
                  }
                  return "Please enter a number!";
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        // TODO: Actions
        MaterialButton(
          onPressed: () {},
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: () {},
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

    final now = DateTime.now();
    final timeDiff = now.difference(subGroup.lastUpdated.toDate());

    if (timeDiff <= _dataTimeGap) {
      final nextDataTime = subGroup.lastUpdated.toDate().add(_dataTimeGap);
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AddDataAlertDialog();
      },
    );
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

        // Add Data Button
        if (writeable) ...[
          const SizedBox(height: 20),
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
        ],
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
