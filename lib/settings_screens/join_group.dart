import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/services/database_service.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _groupCode = "";

  Future<bool> showJoinGroupDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.grey[900],
          title: const Text("Join this group"),
          content: const Text(
            "Are you sure you want to join this group? You will automatically leave your current group.",
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(true),
              color: const Color.fromRGBO(160, 0, 0, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: const Text("Join"),
            ),
          ],
        ),
      ),
    );
  }

  void joinGroup() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final db = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = Provider.of<User?>(context, listen: false);

    db.getAppUser(currentUser!.uid).then((appUser) async {
      if (_groupCode == appUser.groupId) {
        throw Exception("You are already a member of this group.");
      }

      final groupExists = await db.groupExists(_groupCode);

      if (!groupExists) {
        throw Exception("No group was found that matches the given code.");
      }

      if (appUser.groupId == null) {
        return db.updateAppUserGroup(currentUser.uid, _groupCode);
      }

      if (await showJoinGroupDialog()) {
        return db.updateAppUserGroup(currentUser.uid, _groupCode);
      }

      throw Exception("Cancelled group change.");
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully joined group!",
          textAlign: TextAlign.center,
        ),
      ));

      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join a Group"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Group Code",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              TextFormField(
                onSaved: (newValue) => _groupCode = newValue ?? "",
                keyboardType: TextInputType.number,
                autocorrect: false,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: "Group Code",
                  hintText: "1234",
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) != null && value.length == 4) {
                      return null;
                    } else {
                      return "Code must be a 4-digit number";
                    }
                  }
                  return "Please enter a code";
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: joinGroup,
                  color: Colors.grey[900],
                  textColor: Theme.of(context).colorScheme.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.all(15),
                  child: const Text("Join"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
