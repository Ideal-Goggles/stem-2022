import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/my_group_screens/supervisor_view.dart';

class PrincipalView extends StatefulWidget {
  final Group group;
  final String name;
  final List<String> sections;

  const PrincipalView({
    super.key,
    required this.group,
    required this.sections,
    required this.name,
  });

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  late final Map<String, double> _gradeWastage;
  late final Map<String, List<double>> _gradeHealth;
  late final Map<String, double> _gradeWastageForYear;
  late final Map<String, List<double>> _gradeHealthForYear;

  bool _loading = true;

  @override
  void initState() {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final groupId = widget.group.id;

    for (final section in widget.sections) {
      Map<String, double> gradeWastage = {};
      Map<String, List<double>> gradeHealth = {};
      Map<String, double> gradeWastageForYear = {};
      Map<String, List<double>> gradeHealthForYear = {};

      db.getSectionSubGroups(groupId, section).then(
        (subGroups) async {
          for (final subGroup in subGroups) {
            final subGroupGrade =
                subGroup.id.substring(0, subGroup.id.length - 2);

            final wastageFuture = db.getWastageData(groupId, subGroup.id);
            final wastageForYearFuture = db.getWastageDataForYear(
              groupId,
              subGroup.id,
              year: DateTime.now().year,
            );

            final healthFuture = db.getHealthData(groupId, subGroup.id);
            final healthForYearFuture = db.getHealthDataForYear(
              groupId,
              subGroup.id,
              year: DateTime.now().year,
            );

            for (final wastage in await wastageFuture) {
              gradeWastage.update(
                section,
                (w) => w + wastage.totalWastage,
                ifAbsent: () => wastage.totalWastage,
              );
            }
            for (final wastage in await wastageForYearFuture) {
              gradeWastageForYear.update(
                section,
                (w) => w + wastage.totalWastage,
                ifAbsent: () => wastage.totalWastage,
              );
            }

            for (final health in await healthFuture) {
              gradeHealth.update(
                section,
                (h) => [...h, health.healthyPercent],
                ifAbsent: () => [health.healthyPercent],
              );
            }
            for (final health in await healthForYearFuture) {
              gradeHealthForYear.update(
                section,
                (h) => [...h, health.healthyPercent],
                ifAbsent: () => [health.healthyPercent],
              );
            }
          }
        },
      );
      setState(() {
        _gradeWastage = gradeWastage;
        _gradeWastageForYear = gradeWastageForYear;

        _gradeHealth = gradeHealth;
        _gradeHealthForYear = gradeHealthForYear;

        _loading = false;
      });
    }

    super.initState();
  }

  Divider get _divider => const Divider(thickness: 1, color: Colors.white38);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    var totalGradeWastage;
    var totalGradeWastageForYear;
    var totalHealth;
    var totalHealthForYear;

    for (final section in widget.sections) {
      totalGradeWastage += _gradeWastage[section]!;
      totalGradeWastageForYear += _gradeWastageForYear[section]!;
      totalHealth += _gradeHealth[section]!;
      totalHealth += _gradeHealthForYear[section]!;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Past Week:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text("Total wastage: ${totalGradeWastage}g"),
                        Text("Average health: $totalHealth%"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Yearly:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text("Total wastage: ${totalGradeWastage}g"),
                        Text("Average health: $totalHealthForYear%"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Sections",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (final section in widget.sections)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: MaterialButton(
                height: 60,
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: Text("$section Section")),
                        body: SupervisorView(
                          group: widget.group,
                          section: section,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Text(section),
                      ),
                      const Icon(Icons.chevron_right_rounded)
                    ]),
              ),
            )
        ],
      ),
    );
  }
}
