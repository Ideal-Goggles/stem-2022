import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final int points;
  final List<String> admins;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.admins,
  });

  factory Group.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Group(
      id: snapshot.id,
      name: data["name"] ?? "Group",
      description: data["description"] ?? "",
      points: data["points"] ?? 0,
      admins: List<String>.from(data["admins"] ?? []),
    );
  }

  static fromMap(data) {}
}
