import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

class GroupDetails extends StatelessWidget {
  final Group group;

  const GroupDetails({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final storage = Provider.of<StorageService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Group Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    foregroundImage:
                        AssetImage("assets/images/defaultGroupImage.png"),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    group.description,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: "Code: "),
                        TextSpan(
                          text: group.id,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Member List
            StreamBuilder(
              stream: db.streamGroupMembersByRank(group.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "Unable to fetch group members:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final userList = snapshot.data!;

                return Expanded(
                  child: ListView.separated(
                    key: PageStorageKey("groupMemberList-${group.id}"),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    itemCount: userList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final member = userList[index];
                      Color? rankColor;

                      if (index == 0) {
                        rankColor = Colors.yellow[800];
                      } else if (index == 1) {
                        rankColor = const Color.fromRGBO(192, 192, 192, 1);
                      } else if (index == 2) {
                        rankColor = const Color.fromRGBO(205, 127, 50, 1);
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 10),
                        tileColor: Colors.grey[900],
                        shape: const StadiumBorder(),
                        title: Expanded(
                          child: Text(
                            member.displayName,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        trailing: Text(
                          "${member.overallRating} H",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder(
                              future: storage.getUserProfileImage(member.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CircleAvatar(
                                    radius: 20,
                                    foregroundImage:
                                        MemoryImage(snapshot.data!),
                                  );
                                }

                                return const CircleAvatar(
                                  radius: 20,
                                  foregroundImage: AssetImage(
                                      "assets/images/defaultUserImage.jpg"),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "#${index + 1}",
                              style: TextStyle(
                                fontSize: 15,
                                color: rankColor ?? Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
