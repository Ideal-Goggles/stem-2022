import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

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

    return MultiProvider(
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
          subGroup: subGroup!,
          writeable: subGroup.classTeacher == appUser.id,
        );
      },
    );
  }
}

class TeacherView extends StatelessWidget {
  final SubGroup subGroup;
  final bool writeable;

  const TeacherView({
    super.key,
    required this.subGroup,
    required this.writeable,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Teacher View"));
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
