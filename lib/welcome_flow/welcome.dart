import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to Hammit"),
          elevation: 0,
          backgroundColor: Colors.grey.withOpacity(0.05),
        ),
        body: const Center(
          child: Text("Welcome to Hammit!"),
        ));
  }
}
