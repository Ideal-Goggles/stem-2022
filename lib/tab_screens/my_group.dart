import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stem_2022/chart_widgets/monthly_health_chart.dart';

import 'package:stem_2022/misc.dart';
import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/chart_widgets/daily_health_chart.dart';
import 'package:stem_2022/chart_widgets/daily_wastage_chart.dart';
import 'package:stem_2022/chart_widgets/monthly_wastage_chart.dart';

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
            return SupervisorView(
              groupId: group.id,
              section: group.supervisors[appUser.id]!,
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
                  label: Text("Percentage of Healthy Students"),
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

        // Daily Wastage Report
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

        const SizedBox(height: 20),
        _divider,
        Text(
          "Monthly Report of ${subGroup.id}",
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),

        // Monthly Wastage Report
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
      ],
    );
  }
}

class SupervisorView extends StatelessWidget {
  final String section;
  final String groupId;

  const SupervisorView(
      {super.key, required this.section, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView(
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SupervisorSectionsGraph(
                    groupId: groupId,
                    section: section,
                  ),
                ),
              );
            },
            height: 65,
            color: Colors.grey[900],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Text("$section Section Stats"),
          )
        ],
      ),
    );
  }
}

class SupervisorSectionsGraph extends StatelessWidget {
  final String section;
  final String groupId;
  const SupervisorSectionsGraph(
      {super.key, required this.section, required this.groupId});

  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
        appBar: AppBar(title: const Text("Section Wastage Graphs")),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "11\u1d57\u02b0 Grade",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  const Text("Overall Wastage Report",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(
                    height: 5,
                  ),
                  _divider,
                  const SizedBox(
                    height: 5,
                  ),
                  StreamBuilder(
                    stream: db.streamSectionSubGroups(groupId, section),
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

                      final subGroups = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: subGroups.length,
                        itemBuilder: (context, index) {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    right: 5, bottom: 10, left: 5),
                                decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(30)),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: StreamBuilder(
                                        stream: db.streamWastageData(
                                          groupId,
                                          subGroups[index].id,
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          final data = snapshot.data!;
                                          return ListView(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.only(
                                                  top: 15,
                                                  bottom: 15,
                                                  left: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 37, 37, 37),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                    topLeft:
                                                        Radius.circular(30),
                                                    topRight:
                                                        Radius.circular(30),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 16,
                                                      offset:
                                                          const Offset(0, -2),
                                                    )
                                                  ],
                                                ),
                                                child: const Text("Report"),
                                              ),
                                              Container(
                                                height: 250,
                                                padding: const EdgeInsets.only(
                                                    top: 30,
                                                    right: 10,
                                                    left: 10,
                                                    bottom: 30),
                                                child: DailyWastageChart(
                                                  data: data,
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 300,
                                      child: StreamBuilder(
                                        stream: db.streamHealthData(
                                          groupId,
                                          subGroups[index].id,
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          final data = snapshot.data!;
                                          return Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.only(
                                                  top: 15,
                                                  bottom: 15,
                                                  left: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 37, 37, 37),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                    topLeft:
                                                        Radius.circular(30),
                                                    topRight:
                                                        Radius.circular(30),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 16,
                                                      offset:
                                                          const Offset(0, -2),
                                                    )
                                                  ],
                                                ),
                                                child: const Text("Report"),
                                              ),
                                              Container(
                                                height: 250,
                                                padding: const EdgeInsets.only(
                                                    top: 30,
                                                    right: 10,
                                                    left: 10,
                                                    bottom: 30),
                                                child: DailyHealthChart(
                                                  data: data,
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            )
          ]),
        ));
  }
}

class PrincipalView extends StatelessWidget {
  const PrincipalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Principal View"));
  }
}
