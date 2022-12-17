import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stem_2022/models/food_post.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FoodPost>> streamRecentFoodPosts() {
    final collection = _db.collection("foodPosts");
    return collection.snapshots().map((snapshot) => snapshot.docs
        .map((document) => FoodPost.fromFirestore(document))
        .toList());
  }
}
