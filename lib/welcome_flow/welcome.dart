import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to Hammit"),
          elevation: 0,
          backgroundColor: Colors.black87,
        ),
        body: const Center(
          child: Text("Welcome to Hammit!"),
        ));
  }
}
