import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _startTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // final currentUser = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create a Post")),
      body: const Center(child: Text("Coming Soon...")),
    );
  }
}
