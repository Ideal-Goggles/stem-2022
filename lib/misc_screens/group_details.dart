import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_borders/gradient_borders.dart';
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
    final storage = Provider.of<StorageService>(context, listen: false);
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
                  FutureBuilder(
                    future: storage.getGroupImage(group.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          radius: 50,
                          foregroundImage: MemoryImage(snapshot.data!),
                        );
                      }

                      return const CircleAvatar(
                        radius: 50,
                        foregroundImage:
                            AssetImage("assets/images/defaultGroupImage.png"),
                      );
                    },
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

class MemberTile extends StatefulWidget {
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
  State<MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> with TickerProviderStateMixin {
  late AnimationController _streakAnimation;

  @override
  void initState() {
    _streakAnimation = AnimationController(
      vsync: this,
      upperBound: 2 * pi,
      duration: Duration(
        // ignore: division_optimization
        milliseconds: (2000 * pi / 0.75).toInt(),
      ),
    );

    _streakAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _streakAnimation.forward(from: 0);
          break;
        case AnimationStatus.dismissed:
          _streakAnimation.forward(from: 0);
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });

    _streakAnimation.forward();
    super.initState();
  }

  @override
  void dispose() {
    _streakAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final currentUser = Provider.of<User?>(context);
    final showStreak = widget.member.streak >= 3;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      tileColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: widget.borderColor ?? Colors.transparent),
      ),
      title: Wrap(
        direction: Axis.horizontal,
        children: [
          Text(
            widget.member.displayName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          if (widget.member.id == currentUser?.uid) ...[
            const SizedBox(width: 5),
            const Text(
              "(You)",
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ],
      ),
      trailing: Text(
        "${widget.member.overallRating} H",
        style: const TextStyle(color: Colors.grey),
      ),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(
            padding: EdgeInsets.zero,
            minWidth: 0,
            onPressed: () {
              if (showStreak) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${widget.member.displayName} is on a ${widget.member.streak}-day posting streak!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _streakAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: showStreak
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: GradientBoxBorder(
                                width: 1.5,
                                gradient: LinearGradient(
                                  transform:
                                      GradientRotation(_streakAnimation.value),
                                  colors: [
                                    Colors.yellow,
                                    Colors.orange.shade600,
                                    Colors.orange.shade600,
                                    Colors.red,
                                  ],
                                ),
                              ),
                            )
                          : null,
                      child: FutureBuilder(
                        future: storage.getUserProfileImage(widget.member.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              radius: 20,
                              foregroundImage: MemoryImage(snapshot.data!),
                            );
                          }

                          return const CircleAvatar(
                            radius: 20,
                            foregroundImage: AssetImage(
                                "assets/images/defaultUserImage.jpg"),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (showStreak)
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    bottom: -3,
                    end: -5,
                    child: Icon(
                      CupertinoIcons.flame_fill,
                      color: Colors.orange[600],
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          Text(
            "#${widget.rank}",
            style: TextStyle(
              fontSize: 15,
              color: widget.rankColor ?? Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
