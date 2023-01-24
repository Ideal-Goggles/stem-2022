import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/chart_widgets/supervisor_charts/grade_health_comparison_chart.dart';
import 'package:stem_2022/chart_widgets/supervisor_charts/grade_wastage_comparison_chart.dart';

import 'package:stem_2022/my_group_screens/section_subgroup_list.dart';

import 'package:stem_2022/services/database_service.dart';

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
          "Weekly ${widget.section} Section Report",
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

        // Grade Reports
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

        // Class Reports
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

        const SizedBox(height: 20),
        _divider,

        Text(
          "Monthly ${widget.section} Section Report",
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

        // Grade Reports
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

        // Weekly  Reports
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
