import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/models/food_post.dart';
import 'package:stem_2022/models/group.dart';

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

  Future<void> updateAppUser(
      String id, String email, String displayName) async {
    final docRef = _db.collection("users").doc(id);

    try {
      await docRef.update({
        "email": email,
        "displayName": displayName,
      });
    } catch (error) {
      // If updating the document fails, try creating it instead.
      await createAppUser(id, email, displayName);
    }
  }

  Stream<AppUser> streamAppUser(String id) {
    return _db
        .collection("users")
        .doc(id)
        .snapshots()
        .map((document) => AppUser.fromFirestore(document));
  }

  Future<List<FoodPost>> getRecentFoodPosts() async {
    final snapshot = await _db
        .collection("foodPosts")
        .orderBy("dateAdded", descending: true)
        .get();

    return snapshot.docs
        .map((document) => FoodPost.fromFirestore(document))
        .toList();
  }

  Future<List<Group>> getGroupsList() async {
    final snapshot = await _db
        .collection("groups")
        .orderBy("groupPoints", descending: true)
        .get();
    return snapshot.docs
        .map((document) => Group.fromFirestore(document))
        .toList();
  }

  getGroup() {}
}
