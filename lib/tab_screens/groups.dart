import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/misc_screens/group_details.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 15, right: 10, bottom: 10, left: 10),
          child: TextField(
            onChanged: (newValue) => setState(
              () => _searchQuery = newValue.toLowerCase(),
            ),
            decoration: const InputDecoration(
              hintText: 'Search groups...',
              suffixIcon: Icon(CupertinoIcons.search),
            ),
          ),
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
          height: 20,
          color: Colors.white12,
        ),
        StreamBuilder(
          stream: db.streamGroupsByRank(),
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

            List<Group> groupList = [];

            if (_searchQuery.isEmpty) {
              groupList = snapshot.data!;
            } else {
              groupList = snapshot.data!
                  .where((group) =>
                      group.name.toLowerCase().contains(_searchQuery) ||
                      group.description.toLowerCase().contains(_searchQuery))
                  .toList();
            }

            return Expanded(
              child: ListView.separated(
                key: const PageStorageKey("groupList"),
                padding: const EdgeInsets.only(top: 7, bottom: 15),
                itemCount: groupList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  Color? rankColor;

                  if (index == 0) {
                    rankColor = Colors.yellow[800];
                  } else if (index == 1) {
                    rankColor = const Color.fromRGBO(192, 192, 192, 1);
                  } else if (index == 2) {
                    rankColor = const Color.fromRGBO(205, 127, 50, 1);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GroupCard(
                      group: groupList[index],
                      rank: index + 1,
                      rankColor: rankColor,
                    ),
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }
}

class GroupCard extends StatelessWidget {
  final Group group;
  final int rank;
  final Color? rankColor;

  const GroupCard({
    super.key,
    required this.group,
    required this.rank,
    this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetails(group: group),
          ),
        );
      },
      color: Colors.grey[900],
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.all(15),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                "#$rank",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rankColor ?? Colors.white30,
                ),
              ),
              Text(
                "${group.points} H",
                style: const TextStyle(color: Colors.white38),
              )
            ],
          ),
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  group.description,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38),
                )
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_forward)
        ],
      ),
    );
  }
}
