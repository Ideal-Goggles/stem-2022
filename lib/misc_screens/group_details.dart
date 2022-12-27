import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

class GroupDetails extends StatelessWidget {
  final Group group;

  const GroupDetails({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
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
                borderRadius: BorderRadius.circular(35),
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
                      final Color? borderColor =
                          member.id == currentUser?.uid ? Colors.white38 : null;

                      Color? rankColor;

                      if (index == 0) {
                        rankColor = Colors.yellow[800];
                      } else if (index == 1) {
                        rankColor = const Color.fromRGBO(192, 192, 192, 1);
                      } else if (index == 2) {
                        rankColor = const Color.fromRGBO(205, 127, 50, 1);
                      }

                      return MemberTile(
                        member: member,
                        rank: index + 1,
                        rankColor: rankColor,
                        borderColor: borderColor,
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

class MemberTile extends StatelessWidget {
  final AppUser member;
  final int rank;
  final Color? borderColor;
  final Color? rankColor;

  const MemberTile({
    super.key,
    required this.member,
    required this.rank,
    this.borderColor,
    this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final currentUser = Provider.of<User?>(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      tileColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor ?? Colors.transparent),
      ),
      title: Wrap(
        direction: Axis.horizontal,
        children: [
          Text(
            member.displayName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          if (member.id == currentUser?.uid) ...[
            const SizedBox(width: 5),
            const Text(
              "(You)",
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ],
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
                  foregroundImage: MemoryImage(snapshot.data!),
                );
              }

              return const CircleAvatar(
                radius: 20,
                foregroundImage:
                    AssetImage("assets/images/defaultUserImage.jpg"),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            "#$rank",
            style: TextStyle(
              fontSize: 15,
              color: rankColor ?? Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
