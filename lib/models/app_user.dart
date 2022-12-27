import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final int overallRating;
  final Timestamp dateCreated;
  final String? groupId;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.overallRating,
    required this.dateCreated,
    this.groupId,
  });

  // TODO: Change to `fromMap`
  factory AppUser.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return AppUser(
      id: snapshot.id,
      email: data["email"],
      displayName: data["displayName"],
      overallRating: data["overallRating"],
      dateCreated: data["dateCreated"],
      groupId: data["groupId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "displayName": displayName,
      "overallRating": overallRating,
      "dateCreated": dateCreated,
      "groupId": groupId,
    };
  }
}
