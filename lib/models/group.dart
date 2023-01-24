import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final int points;
  final Map<String, String> supervisors;
  final String admin;
  final List sections;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.supervisors,
    required this.admin,
    required this.sections,
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
      sections: data["sections"],
    );
  }
}

class SubGroup {
  final String id;
  final String classTeacher;
  final String section;
  final int points;
  final Timestamp? lastUpdated;

  const SubGroup({
    required this.id,
    required this.classTeacher,
    required this.section,
    required this.points,
    required this.lastUpdated,
  });

  factory SubGroup.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return SubGroup(
      id: snapshot.id,
      classTeacher: data["classTeacher"],
      section: data["section"],
      points: data["points"],
      lastUpdated: data["lastUpdated"],
    );
  }
}

class HealthDataPoint {
  final String id;
  final double healthyPercent;
  final Timestamp timestamp;

  const HealthDataPoint({
    required this.id,
    required this.healthyPercent,
    required this.timestamp,
  });

  factory HealthDataPoint.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return HealthDataPoint(
      id: snapshot.id,
      healthyPercent: data["healthyPercent"],
      timestamp: data["timestamp"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "healthyPercent": healthyPercent,
      "timestamp": timestamp,
    };
  }
}

class WastageDataPoint {
  final String id;
  final double totalWastage;
  final Timestamp timestamp;

  const WastageDataPoint({
    required this.id,
    required this.totalWastage,
    required this.timestamp,
  });

  factory WastageDataPoint.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return WastageDataPoint(
      id: snapshot.id,
      totalWastage: data["totalWastage"].toDouble(),
      timestamp: data["timestamp"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "totalWastage": totalWastage,
      "timestamp": timestamp,
    };
  }
}

class GroupAnnouncement {
  final String id;
  final String authorId;
  final String content;
  final Timestamp dateAdded;
  final String? targetSection;

  const GroupAnnouncement({
    required this.id,
    required this.authorId,
    required this.content,
    required this.dateAdded,
    this.targetSection,
  });

  factory GroupAnnouncement.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return GroupAnnouncement(
      id: snapshot.id,
      authorId: data["authorId"],
      content: data["content"],
      dateAdded: data["dateAdded"],
      targetSection: data["targetSection"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "content": content,
      "dateAdded": dateAdded,
      "targetSection": targetSection,
    };
  }
}
