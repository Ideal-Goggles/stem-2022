import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _startTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // TODO
    return Scaffold(
      appBar: AppBar(title: const Text("Create a Post")),
      body: const Center(child: Text("Coming Soon...")),
    );
  }
}
