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

  Future<void> deleteFoodPost(String foodPostId) async {
    final docRef = _db.collection("foodPosts").doc(foodPostId);
    await docRef.delete();
  }

  Future<bool> foodPostRatingExists(String foodPostId, String userId) async {
    final snapshot = await _db
        .collection("foodPosts")
        .doc(foodPostId)
        .collection("ratings")
        .doc(userId)
        .get();

    return snapshot.exists;
  }

  Future<void> addFoodPostRating(
      String foodPostId, String userId, int rating) async {
    final docRef = _db
        .collection("foodPosts")
        .doc(foodPostId)
        .collection("ratings")
        .doc(userId);

    final ratingData = {"rating": rating};
    await docRef.set(ratingData);
  }

  Future<bool> groupExists(String groupId) async {
    final snapshot = await _db.collection("groups").doc(groupId).get();
    return snapshot.exists;
  }

  Stream<Group> streamGroup(String groupId) {
    return _db
        .collection("groups")
        .doc(groupId)
        .snapshots()
        .map((document) => Group.fromFirestore(document));
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

  Stream<SubGroup> streamSubGroup(String groupId, String subGroupId) {
    return _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId)
        .snapshots()
        .map((document) => SubGroup.fromFirestore(document));
  }

  Stream<List<WastageDataPoint>> streamWastageData(
    String groupId,
    String subGroupId, {
    int limit = 5,
  }) {
    final snapshotStream = _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId)
        .collection("wastage")
        .orderBy("timestamp")
        .limit(limit)
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => WastageDataPoint.fromFirestore(document))
          .toList(),
    );
  }

  Stream<List<HealthDataPoint>> streamHealthData(
    String groupId,
    String subGroupId, {
    int limit = 5,
  }) {
    final snapshotStream = _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId)
        .collection("health")
        .orderBy("timestamp")
        .limit(limit)
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => HealthDataPoint.fromFirestore(document))
          .toList(),
    );
  }

  Stream<List<WastageDataPoint>> streamWastageDataForYear(
    String groupId,
    String subGroupId, {
    required int year,
  }) {
    final yearBegin = DateTime(year);
    final yearEnd = yearBegin.add(const Duration(days: 365));

    final snapshotStream = _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId)
        .collection("wastage")
        .orderBy("timestamp")
        .where(
          "timestamp",
          isGreaterThan: Timestamp.fromDate(yearBegin),
          isLessThan: Timestamp.fromDate(yearEnd),
        )
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => WastageDataPoint.fromFirestore(document))
          .toList(),
    );
  }

  Stream<List<HealthDataPoint>> streamHealthDataForYear(
    String groupId,
    String subGroupId, {
    required int year,
  }) {
    final yearBegin = DateTime(year);
    final yearEnd = yearBegin.add(const Duration(days: 365));

    final snapshotStream = _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId)
        .collection("health")
        .orderBy("timestamp")
        .where(
          "timestamp",
          isGreaterThan: Timestamp.fromDate(yearBegin),
          isLessThan: Timestamp.fromDate(yearEnd),
        )
        .snapshots();

    return snapshotStream.map(
      (snapshot) => snapshot.docs
          .map((document) => HealthDataPoint.fromFirestore(document))
          .toList(),
    );
  }

  Future<void> addSubGroupData({
    required String groupId,
    required String subGroupId,
    required double totalWastage,
    required double healthyPercent,
  }) async {
    final subGroupDocRef = _db
        .collection("groups")
        .doc(groupId)
        .collection("subgroups")
        .doc(subGroupId);

    final wastageDocRef = subGroupDocRef.collection("wastage").doc();
    final healthDocRef = subGroupDocRef.collection("health").doc();

    final now = Timestamp.now();
    final wastageData = WastageDataPoint(
        id: wastageDocRef.id, totalWastage: totalWastage, timestamp: now);
    final healthData = HealthDataPoint(
        id: healthDocRef.id, healthyPercent: healthyPercent, timestamp: now);

    final wastageFuture = wastageDocRef.set(wastageData.toMap());
    final healthFuture = healthDocRef.set(healthData.toMap());

    // Update subgroup after adding new datapoints
    return wastageFuture
        .then((_) => healthFuture)
        .then((_) => subGroupDocRef.update({"lastUpdated": now}));
  }
}
