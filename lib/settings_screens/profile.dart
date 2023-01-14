import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

import "package:stem_2022/misc_screens/edit_user_profile.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          backgroundColor: Colors.grey[900],
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(true),
              color: const Color.fromRGBO(160, 0, 0, 1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              elevation: 0,
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    ).then((logoutConfirmed) {
      if (logoutConfirmed) logout(context);
    });
  }

  void logout(BuildContext context) {
    final googleSignIn = GoogleSignIn();

    googleSignIn.signOut();
    FirebaseAuth.instance.signOut().then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final storage = Provider.of<StorageService>(context);
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, ${currentUser?.displayName}"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditUserProfileScreen(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.pencil)),
        ],
      ),
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
                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            foregroundImage: MemoryImage(snapshot.data!),
                          ),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          foregroundImage:
                              AssetImage("assets/images/defaultUserImage.jpg"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    currentUser.displayName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Healthy Food Eater",
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.flame_fill,
                          color: Colors.orange[600]),
                      const SizedBox(width: 3),
                      StreamBuilder(
                        stream: db.streamAppUser(currentUser.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final appUser = snapshot.data!;
                            return Text(
                              appUser.streak.toString(),
                              style: TextStyle(color: Colors.grey[300]),
                            );
                          }

                          return SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: () => showLogoutDialog(context),
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
