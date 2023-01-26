import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/my_group_screens/teacher_view.dart';

class SectionSubGroupListScreen extends StatelessWidget {
  final Group group;
  final String section;

  const SectionSubGroupListScreen({
    super.key,
    required this.group,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text("$section Section Classes")),
      body: StreamBuilder(
        stream: db.streamSectionSubGroups(group.id, section),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 20,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final subGroups = snapshot.data!;
          subGroups.sort((a, b) => a.id.compareTo(b.id)); // Sort by ID

          return ListView.separated(
            padding: const EdgeInsets.all(12).add(
              const EdgeInsets.only(top: 4, bottom: 40),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: subGroups.length,
            itemBuilder: (context, index) {
              return SubGroupListTile(
                group: group,
                subGroup: subGroups[index],
              );
            },
          );
        },
      ),
    );
  }
}

class SubGroupListTile extends StatelessWidget {
  final Group group;
  final SubGroup subGroup;

  const SubGroupListTile({
    super.key,
    required this.group,
    required this.subGroup,
  });

  void _navigateToTeacherView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: true,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text("Details for ${subGroup.id}")),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TeacherView(
                group: group,
                subGroup: subGroup,
                writeable: false,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => _navigateToTeacherView(context),
      padding: const EdgeInsets.all(15),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subGroup.id,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}
