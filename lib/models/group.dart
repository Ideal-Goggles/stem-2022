import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final int rank;
  final int points;
  final List<String> admins;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.rank,
    required this.points,
    required this.admins,
  });

  factory Group.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Group(
      id: snapshot.id,
      name: data["name"],
      description: data["description"],
      rank: data["rank"],
      points: data["points"],
      admins: List<String>.from(data["admins"]),
    );
  }

  static fromMap(data) {}
}