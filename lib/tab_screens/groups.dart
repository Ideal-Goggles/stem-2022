import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController(keepScrollOffset: true);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final db = Provider.of<DatabaseService>(context, listen: false);

    return StreamBuilder(
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

        final groupList = snapshot.data!;

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 15),
          itemCount: groupList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            Color? rankColor;

            if (index == 0) {
              rankColor = Colors.yellow[800];
            } else if (index == 1) {
              rankColor = Colors.white70;
            } else if (index == 2) {
              rankColor = Colors.brown[800];
            }

            return GroupCard(
                group: groupList[index], rank: index + 1, rankColor: rankColor);
          },
        );
      },
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: MaterialButton(
        onPressed: () {},
        color: Colors.grey[900],
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    group.description,
                    style: const TextStyle(color: Colors.white38),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }
}
