import 'package:flutter/material.dart';
import 'package:stem_2022/welcome_flow/welcome.dart';
import 'package:stem_2022/welcome_flow/account.dart';

class SettingsMenuEntry {
  final IconData icon;
  final String text;
  final Widget destination;

  SettingsMenuEntry(this.icon, this.text, this.destination);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static List<SettingsMenuEntry> entries = [
    SettingsMenuEntry(Icons.help, "What is Hammit?", const WelcomeScreen()),
    SettingsMenuEntry(Icons.person, "Account", const AccountScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.transparent, height: 8),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.only(top: 10),
              child: MaterialButton(
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
              ),
            );
          }),
    );
  }
}
