import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPost {
  final String id;
  final String authorId;
  final String caption;
  final int totalRating;
  final int numberOfRatings;
  final Timestamp dateAdded;

  FoodPost({
    required this.id,
    required this.authorId,
    required this.caption,
    required this.totalRating,
    required this.numberOfRatings,
    required this.dateAdded,
  });

  // TODO: Change to `fromMap`
  factory FoodPost.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return FoodPost(
      id: snapshot.id,
      authorId: data["authorId"],
      caption: data["caption"],
      totalRating: data["totalRating"],
      numberOfRatings: data["numberOfRatings"],
      dateAdded: data["dateAdded"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "caption": caption,
      "totalRating": totalRating,
      "numberOfRatings": numberOfRatings,
      "dateAdded": dateAdded,
    };
  }
}
