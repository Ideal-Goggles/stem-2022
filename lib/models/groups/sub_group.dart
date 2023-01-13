import 'package:cloud_firestore/cloud_firestore.dart';

class SubGroup {
  final String id;
  final String classTeacher;
  final String section;
  final int points;
  final Timestamp lastUpdated;

  const SubGroup({
    required this.id,
    required this.classTeacher,
    required this.section,
    required this.points,
    required this.lastUpdated,
  });
}
