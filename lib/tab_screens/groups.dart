import 'package:flutter/material.dart';
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
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: MaterialButton(
            onPressed: () {},
            color: Colors.grey[900],
            textColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(15),
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "#${group.groupRank}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: group.groupRank == 1
                              ? Colors.yellow[800]
                              : group.groupRank == 2
                                  ? Colors.white70
                                  : group.groupRank == 3
                                      ? Colors.brown[900]
                                      : Colors.white30),
                    ),
                    Text("${group.groupPoints} H",
                        style: TextStyle(color: Colors.white38))
                  ],
                ),
                Container(
                  width: 200,
                  child: Column(
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        group.description,
                        style: TextStyle(color: Colors.white38),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                Icon(Icons.chevron_right)
              ],
            )));
  }
}
