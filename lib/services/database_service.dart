import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/food_post.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createAppUser(
      String id, String email, String displayName) async {
    final appUser = AppUser(
      id: id,
      email: email,
      displayName: displayName,
      overallRating: 0,
      dateCreated: Timestamp.now(),
    );

    final docRef = _db.collection("users").doc(id);
    await docRef.set(appUser.toMap());
  }

  Stream<List<FoodPost>> streamRecentFoodPosts() {
    final collection = _db.collection("foodPosts");
    return collection.snapshots().map((snapshot) => snapshot.docs
        .map((document) => FoodPost.fromFirestore(document))
        .toList());
  }
}
