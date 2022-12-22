import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final int groupRank;
  final int groupPoints;
  final List<String> admins;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.groupRank,
    required this.groupPoints,
    required this.admins,
  });

  factory Group.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Group(
      id: snapshot.id,
      name: data["name"],
      description: data["description"],
      groupRank: data["groupRank"],
      groupPoints: data["groupPoints"],
      admins: List<String>.from(data["admins"]),
    );
  }

  static fromMap(data) {}
}
