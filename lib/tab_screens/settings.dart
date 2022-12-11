import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            leading: Icon(Icons.help),
            title: Text(
              "What is Ideal Food?",
            ),
          ),
        ]);
  }
}
