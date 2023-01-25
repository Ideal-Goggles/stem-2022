import 'package:flutter/material.dart';

class PrincipalView extends StatelessWidget {
  final String groupId;
  final List<String> sections;

  const PrincipalView({
    super.key,
    required this.groupId,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return const Center(child: Text("Principal"));
      },
    );
  }
}
