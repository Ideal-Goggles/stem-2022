import 'package:flutter/material.dart';

import 'package:stem_2022/models/group.dart';

class GroupDetails extends StatelessWidget {
  final Group group;

  const GroupDetails({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    foregroundImage:
                        AssetImage("assets/images/defaultUserImage.jpg"),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    group.description,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
