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

  Future<void> updateAppUserDetails(
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

  Future<void> updateAppUserGroup(String userId, String groupId) async {
    final docRef = _db.collection("users").doc(userId);
    await docRef.update({"groupId": groupId});
  }

  Future<AppUser> getAppUser(String id) async {
    final docRef = _db.collection("users").doc(id);
    final snapshot = await docRef.get();
    return AppUser.fromFirestore(snapshot);
  }

  Stream<AppUser> streamAppUser(String id) {
    return _db
        .collection("users")
        .doc(id)
        .snapshots()
        .map((document) => AppUser.fromFirestore(document));
  }

  Future<FoodPost?> getUserLatestFoodPost(String userId) async {
    final snapshot = await _db
        .collection("foodPosts")
        .where("authorId", isEqualTo: userId)
        .orderBy("dateAdded", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return FoodPost.fromFirestore(snapshot.docs.first);
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

  Future<String> createFoodPost(String authorId, String caption) async {
    final foodPost = FoodPost(
      id: "",
      authorId: authorId,
      caption: caption,
      totalRating: 0,
      numberOfRatings: 0,
      dateAdded: Timestamp.now(),
    );

    final docRef = _db.collection("foodPosts").doc();
    await docRef.set(foodPost.toMap());

    return docRef.id;
  }

  Future<bool> groupExists(String groupId) async {
    final snapshot = await _db.collection("groups").doc(groupId).get();
    return snapshot.exists;
  }

  Future<List<Group>> getGroupsList() async {
    final snapshot = await _db
        .collection("groups")
        .orderBy("points", descending: true)
        .get();

    return snapshot.docs
        .map((document) => Group.fromFirestore(document))
        .toList();
  }

  Stream<List<Group>> streamGroupsByRank() {
    final snapshotStream = _db
        .collection("groups")
        .orderBy("points", descending: true)
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => Group.fromFirestore(document))
          .toList(),
    );
  }

  Stream<List<AppUser>> streamGroupMembersByRank(String groupId) {
    final snapshotStream = _db
        .collection("users")
        .where("groupId", isEqualTo: groupId)
        .orderBy("overallRating", descending: true)
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => AppUser.fromFirestore(document))
          .toList(),
    );
  }
}
