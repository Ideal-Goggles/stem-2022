import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final int points;
  final Map<String, String> supervisors;
  final String admin;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.supervisors,
    required this.admin,
  });

  factory Group.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Group(
      id: snapshot.id,
      name: data["name"],
      description: data["description"],
      points: data["points"],
      supervisors: Map<String, String>.from(data["supervisors"]),
      admin: data["admin"],
    );
  }
}
