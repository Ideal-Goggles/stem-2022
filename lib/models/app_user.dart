import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final int overallRating;
  final Timestamp dateCreated;
  final int trueStreak;
  final String? groupId;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.overallRating,
    required this.dateCreated,
    required this.trueStreak,
    this.groupId,
  });

  static AppUser get previewUser => AppUser(
        id: "",
        email: "user@mail.com",
        displayName: "User",
        overallRating: 0,
        dateCreated: Timestamp.now(),
        trueStreak: -1,
      );

  int get streak => max(0, trueStreak);

  // TODO: Change to `fromMap`
  factory AppUser.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return AppUser(
      id: snapshot.id,
      email: data["email"] ?? "",
      displayName: data["displayName"] ?? "User",
      overallRating: data["overallRating"] ?? 0,
      dateCreated: data["dateCreated"] ?? Timestamp.now(),
      trueStreak: data["streak"] ?? -1,
      groupId: data["groupId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "displayName": displayName,
      "overallRating": overallRating,
      "dateCreated": dateCreated,
      "streak": trueStreak,
      "groupId": groupId,
    };
  }
}
