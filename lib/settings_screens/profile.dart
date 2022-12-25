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
                  Text(
                    "${currentUser.displayName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
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
              onPressed: () => logout(context),
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
