import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPost {
  final String id;
  final String authorId;
  final String caption;
  final int totalRatings;
  final int numberOfRatings;
  final Timestamp dateAdded;

  FoodPost({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.totalRatings,
    required this.numberOfRatings,
    required this.dateAdded,
  });

  factory FoodPost.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return FoodPost(
      id: snapshot.id,
      authorId: data["authorId"],
      caption: data["caption"],
      totalRatings: data["totalRatings"],
      numberOfRatings: data["numberOfRatings"],
      dateAdded: data["dateAdded"],
    );
  }
}
