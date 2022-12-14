import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stem_2022/settings_screens/login.dart';

import 'package:stem_2022/settings_screens/welcome.dart';
import 'package:stem_2022/settings_screens/sign_up.dart';

class SettingsMenuEntry {
  final IconData icon;
  final String text;
  final Widget destination;

  SettingsMenuEntry(this.icon, this.text, this.destination);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final List<SettingsMenuEntry> entries = [
      SettingsMenuEntry(Icons.help, "What is Hammit?", const WelcomeScreen()),
      if (currentUser == null)
        SettingsMenuEntry(Icons.app_registration_rounded, "Create an Account",
            const SignUpScreen()),
      if (currentUser == null)
        SettingsMenuEntry(
            Icons.login, "Log Into Existing Account", const LoginScreen())
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.transparent, height: 18),
          itemBuilder: (BuildContext context, int index) {
            return MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => entries[index].destination,
                  ),
                );
              },
              color: Colors.grey.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
              child: ListTile(
                leading: Icon(entries[index].icon),
                title: Text(entries[index].text),
              ),
            );
          }),
    );
  }
}
