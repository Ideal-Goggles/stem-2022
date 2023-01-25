import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

class GroupAnnouncementsScreen extends StatelessWidget {
  final Group group;
  final bool writeable;
  final String? section;

  const GroupAnnouncementsScreen({
    super.key,
    required this.group,
    required this.writeable,
    this.section,
  });

  void _showAddAnnouncementDialog(BuildContext context) {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$section Section Announcements",
          overflow: TextOverflow.fade,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddAnnouncementDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: db.streamGroupAnnouncements(group.id, section),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcementsList = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8).add(const EdgeInsets.only(top: 4)),
            separatorBuilder: (context, index) => const Divider(height: 15),
            itemCount: announcementsList.length,
            itemBuilder: (context, index) {
              return AnnouncementCard(
                announcement: announcementsList[index],
              );
            },
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final GroupAnnouncement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  /// January = 0, December = 11
  String? _monthIntToString(int month) {
    switch (month) {
      case DateTime.january:
        return "January";
      case DateTime.february:
        return "February";
      case DateTime.march:
        return "March";
      case DateTime.april:
        return "April";
      case DateTime.may:
        return "May";
      case DateTime.june:
        return "June";
      case DateTime.july:
        return "July";
      case DateTime.august:
        return "August";
      case DateTime.september:
        return "September";
      case DateTime.october:
        return "October";
      case DateTime.november:
        return "November";
      case DateTime.december:
        return "December";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final dateAdded = announcement.dateAdded.toDate();

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: db.streamAppUser(announcement.authorId),
              builder: (context, snapshot) {
                return Text(
                  "Announcement by ${snapshot.data?.displayName ?? "Unknown"}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Text(
              "on ${dateAdded.day} ${_monthIntToString(dateAdded.month)} ${dateAdded.year}",
              style: const TextStyle(fontSize: 14, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            Text(
              announcement.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
