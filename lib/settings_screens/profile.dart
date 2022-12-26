import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:stem_2022/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout(BuildContext context) {
    final googleSignIn = GoogleSignIn();

    googleSignIn.signOut();
    FirebaseAuth.instance.signOut().then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final storage = Provider.of<StorageService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Hello, ${currentUser?.displayName}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: storage.getUserProfileImage(currentUser!.uid),
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
                            AssetImage("assets/images/defaultUserImage.jpg"),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${currentUser.displayName}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          final newDisplayName = await showDialog(
                            context: context,
                            builder: (context) => const EditNameDialog(),
                          );
                          if (newDisplayName != null) {
                            await currentUser.updateDisplayName(newDisplayName);
                          }
                        },
                        child: const Icon(Icons.edit_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Professional Cat",
                    style: TextStyle(color: Colors.grey[300]),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    backgroundColor: Colors.grey[900],
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      MaterialButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      MaterialButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        color: const Color.fromRGBO(70, 0, 0, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        elevation: 0,
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed) {
                  // ignore: use_build_context_synchronously
                  logout(context);
                }
              },
              color: const Color.fromRGBO(70, 0, 0, 1),
              shape: const StadiumBorder(),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 25),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({super.key});

  @override
  EditNameDialogState createState() => EditNameDialogState();
}

class EditNameDialogState extends State<EditNameDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Edit Username'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(hintText: 'New username'),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          elevation: 0,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
