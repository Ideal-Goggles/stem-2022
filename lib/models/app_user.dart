import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final int overallRating;
  final Timestamp dateCreated;
  final int streak;
  final String? groupId;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.overallRating,
    required this.dateCreated,
    required this.streak,
    this.groupId,
  });

  static AppUser get previewUser => AppUser(
        id: "",
        email: "user@mail.com",
        displayName: "User",
        overallRating: 0,
        dateCreated: Timestamp.now(),
        streak: 0,
      );

  // TODO: Change to `fromMap`
  factory AppUser.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return AppUser(
      id: snapshot.id,
      email: data["email"] ?? "",
      displayName: data["displayName"] ?? "User",
      overallRating: data["overallRating"] ?? 0,
      dateCreated: data["dateCreated"] ?? Timestamp.now(),
      streak: data["streak"] ?? 0,
      groupId: data["groupId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "displayName": displayName,
      "overallRating": overallRating,
      "dateCreated": dateCreated,
      "streak": streak,
      "groupId": groupId,
    };
  }
}
