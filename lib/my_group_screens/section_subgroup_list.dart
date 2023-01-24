import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/services/database_service.dart';

class SectionSubGroupListScreen extends StatelessWidget {
  final String groupId;
  final String section;

  const SectionSubGroupListScreen({
    super.key,
    required this.groupId,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return StreamBuilder(
      stream: db.streamSectionSubGroups(groupId, section),
      builder: (context, snapshot) {
        throw UnimplementedError();
      },
    );
  }
}
