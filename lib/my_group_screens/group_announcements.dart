import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/models/group.dart';
import 'package:stem_2022/services/database_service.dart';

class GroupAnnouncementsScreen extends StatelessWidget {
  final Group group;
  final bool writeable;
  final String section;

  const GroupAnnouncementsScreen({
    super.key,
    required this.group,
    required this.writeable,
    required this.section,
  });

  void _showAddAnnouncementDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) => const AddAnnouncementAlert(),
    ).then((content) {
      if (content == null) {
        throw Exception("Announcement Cancelled");
      }

      final db = Provider.of<DatabaseService>(context, listen: false);
      return db.createGroupAnnouncement(
        content: content,
        authorId: FirebaseAuth.instance.currentUser!.uid,
        groupId: group.id,
        targetSection: section,
      );
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully created new announcement!",
          textAlign: TextAlign.center,
        ),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString(), textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
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
        actions: writeable
            ? [
                IconButton(
                  onPressed: () => _showAddAnnouncementDialog(context),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ]
            : null,
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
                section: section,
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
  final String section;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.section,
  });

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
    final dateAdded = announcement.dateAdded.toDate();

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Announcement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "by $section Supervisor",
              style: const TextStyle(fontSize: 14, color: Colors.white38),
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

class AddAnnouncementAlert extends StatefulWidget {
  const AddAnnouncementAlert({super.key});

  @override
  State<AddAnnouncementAlert> createState() => _AddAnnouncementAlertState();
}

class _AddAnnouncementAlertState extends State<AddAnnouncementAlert> {
  final _formKey = GlobalKey<FormState>();
  String _content = "";

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.grey[900],
        title: const Text("Create an Announcement"),
        content: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: TextFormField(
              onSaved: (newValue) => _content = newValue ?? "",
              minLines: 6,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                fillColor: Colors.black38,
                label: Text("Enter content for posting an announcement."),
                hintText: "Hello World!",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter some information";
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context, _content);
              }
            },
            color: const Color.fromRGBO(13, 71, 161, 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
