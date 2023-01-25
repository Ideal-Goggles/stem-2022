import 'package:flutter/material.dart';
import 'package:stem_2022/my_group_screens/supervisor_view.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sections",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          for (final section in sections)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: MaterialButton(
                height: 75,
                color: Colors.grey[900],
                shape: const StadiumBorder(),
                onPressed: () {},
                child: Text(section),
              ),
            )
        ],
      ),
    );
  }
}
