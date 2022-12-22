import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final db = Provider.of<DatabaseService>(context, listen: false);

    return FutureBuilder(
      future: db.getGroupsList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error.toString()}",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: Text("Loading..."));
        }

        final groupList = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.only(top: 15),
          itemCount: groupList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) => GroupCard(group: groupList[index]),
        );
      },
    );
  }
}

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final db = Provider.of<DatabaseService>(context);
    return MaterialButton(
        onPressed: () {},
        color: Colors.grey[900],
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(group.name,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  group.description,
                  style: TextStyle(color: Colors.white38),
                )
              ],
            ),
            Icon(Icons.chevron_right)
          ],
        ));
  }
}
