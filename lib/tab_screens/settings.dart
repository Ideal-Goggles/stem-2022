import 'package:flutter/material.dart';
import 'package:stem_2022/welcome_flow/welcome.dart';

class SettingsMenuEntry {
  final IconData icon;
  final String text;
  final Widget Function() destination;

  SettingsMenuEntry(this.icon, this.text, this.destination);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static List<SettingsMenuEntry> entries = [
    SettingsMenuEntry(
        Icons.help, "What is Ideal Food?", () => const WelcomeScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.transparent, height: 8),
        itemBuilder: (BuildContext context, int index) {
          return MaterialButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => entries[index].destination()));
              },
              color: Colors.blueGrey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              child: ListTile(
                leading: Icon(entries[index].icon),
                title: Text(entries[index].text),
              ));
        });
  }
}
