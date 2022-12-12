import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Welcome to Ideal Food")),
        body: const Center(
          child: Text("Welcome to Ideal Food!"),
        ));
  }
}
