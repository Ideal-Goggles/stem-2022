import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to Account"),
          elevation: 0,
          backgroundColor: Colors.black87,
        ),
        body: const Center(
          child: Text("Welcome to Hammit!"),
        ));
  }
}
