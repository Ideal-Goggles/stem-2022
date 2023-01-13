import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyGroupScreen extends StatelessWidget {
  const MyGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);

    return const Center(child: Text("Coming Soon..."));
  }
}
