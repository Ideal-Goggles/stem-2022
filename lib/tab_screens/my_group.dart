import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/services/database_service.dart';

class MyGroupScreen extends StatelessWidget {
  const MyGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final appUser = Provider.of<AppUser?>(context);

    if (appUser == null) {
      return const Center(
        child: Text(
          "Log in to view group details",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    if (appUser.groupId == null) {
      return const Center(
        child: Text(
          "Join a group to view group details",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return StreamProvider.value(
        value: db.streamGroup(appUser.groupId!), initialData: null);
  }
}

class TeacherView extends StatelessWidget {
  const TeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Teacher View"));
  }
}

class SupervisorView extends StatelessWidget {
  const SupervisorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Supervisor View"));
  }
}

class PrincipalView extends StatelessWidget {
  const PrincipalView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Principal View"));
  }
}
