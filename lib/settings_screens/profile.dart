import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:stem_2022/tab_screens/settings.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() async {
      _googleSignIn.signOut();
      FirebaseAuth.instance.signOut().then((__) => Navigator.pop(context));
    }

    final currentUser = Provider.of<User?>(context);
    return Scaffold(
        appBar: AppBar(title: Text("Hello, ${currentUser?.displayName}")),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              "https://cdn.discordapp.com/attachments/1002490022487928913/1054449807021842442/lokipoki.jpeg"),
                        )),
                    Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${currentUser?.displayName}",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600),
                            ),
                            Text("Professional Cat")
                          ],
                        )),
                  ],
                ),
              ),
              SizedBox(height: 10),
              MaterialButton(
                  minWidth: double.infinity,
                  onPressed: logout,
                  color: Colors.red.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 25),
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  ))
            ],
          ),
        ));
  }
}
