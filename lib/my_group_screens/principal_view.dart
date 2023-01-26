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
  late double _schoolWastage;
  late List<double> _schoolHealth;
  late double _schoolWastageForYear;
  late List<double> _schoolHealthForYear;

  bool _loading = true;

  @override
  void initState() {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final groupId = widget.group.id;

    double schoolWastage = 0;
    List<double> schoolHealth = [];
    double schoolWastageForYear = 0;
    List<double> schoolHealthForYear = [];

    db.getSubGroups(groupId).then(
      (subGroups) async {
        for (final subGroup in subGroups) {
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
            schoolWastage += wastage.totalWastage;
          }
          for (final wastage in await wastageForYearFuture) {
            schoolWastageForYear += wastage.totalWastage;
          }

          for (final health in await healthFuture) {
            schoolHealth.add(health.healthyPercent);
          }
          for (final health in await healthForYearFuture) {
            schoolHealthForYear.add(health.healthyPercent);
          }
        }

        setState(() {
          _schoolWastage = schoolWastage;
          _schoolWastageForYear = schoolWastageForYear;

          _schoolHealth = schoolHealth;
          _schoolHealthForYear = schoolHealthForYear;

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

    final totalSchoolHealth = _schoolHealth.reduce((a, b) => a + b);
    final avgSchoolHealth = totalSchoolHealth * 100 / _schoolHealth.length;

    final totalSchoolHealthForYear =
        _schoolHealthForYear.reduce((a, b) => a + b);
    final avgSchoolHealthForYear =
        totalSchoolHealthForYear * 100 / _schoolHealthForYear.length;

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(14),
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
                const SizedBox(height: 15),
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
                        Text("Total wastage: ${_schoolWastage}g"),
                        Text(
                          "Average health: ${avgSchoolHealth.toStringAsPrecision(4)}%",
                        ),
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
                        Text("Total wastage: ${_schoolWastageForYear}g"),
                        Text(
                          "Average health: ${avgSchoolHealthForYear.toStringAsPrecision(4)}%",
                        ),
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
              fontSize: 24,
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
                        body: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SupervisorView(
                            group: widget.group,
                            section: section,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Text(
                        section,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
