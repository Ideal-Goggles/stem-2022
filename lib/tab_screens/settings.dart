import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/settings_screens/welcome.dart';
import 'package:stem_2022/settings_screens/sign_up.dart';
import 'package:stem_2022/settings_screens/login.dart';
import 'package:stem_2022/settings_screens/profile.dart';
import 'package:stem_2022/settings_screens/join_group.dart';

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
    final user = Provider.of<User?>(context);
    final loggedIn = user != null;

    final List<SettingsMenuEntry> entries = [
      SettingsMenuEntry(CupertinoIcons.question_circle_fill,
          "What is HeLP@MPS?", const WelcomeScreen()),
      if (!loggedIn) ...[
        SettingsMenuEntry(Icons.perm_contact_calendar, "Create an Account",
            const SignUpScreen()),
        SettingsMenuEntry(
            Icons.login, "Log Into Existing Account", const LoginScreen())
      ],
      if (loggedIn) ...[
        SettingsMenuEntry(
            CupertinoIcons.person_fill, "Profile", const ProfileScreen()),
        SettingsMenuEntry(
            Icons.group_add_rounded, "Join Group", const JoinGroupScreen()),
      ],
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 20),
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
          color: Colors.grey[900],
          shape: const StadiumBorder(),
          elevation: 0,
          child: ListTile(
            leading: Icon(entries[index].icon),
            title: Text(entries[index].text),
          ),
        );
      },
    );
  }
}
