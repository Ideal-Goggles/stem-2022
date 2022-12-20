import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _secondsLeft = 60;

  Future timer() async {
    while (_secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      setState(() => _secondsLeft--);
    }
  }

  @override
  void initState() {
    super.initState();
    timer(); // Start the timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a Post")),
      body: Center(child: Text("$_secondsLeft")),
    );
  }
}
