import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static const _maxSize = 5 * 1024 * 1024;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<String, Uint8List> _foodPostImageCache = {};
  final Map<String, Uint8List> _userProfileImageCache = {};
  final Map<String, Uint8List> _groupImageCache = {};

  Future<Uint8List?> getFoodPostImage(String foodPostId) async {
    if (_foodPostImageCache.containsKey(foodPostId)) {
      return _foodPostImageCache[foodPostId];
    }

    final storageRef = _storage.ref("foodPostImages").child("$foodPostId.jpg");
    final imageData = await storageRef.getData(_maxSize);

    if (imageData != null) _foodPostImageCache[foodPostId] = imageData;
    return imageData;
  }

  Future<void> setFoodPostImage(String foodPostId, Uint8List imageData) async {
    final storageRef = _storage.ref("foodPostImages").child("$foodPostId.jpg");
    await storageRef.putData(
      imageData,
      SettableMetadata(contentType: "image/jpeg"),
    );

    _foodPostImageCache[foodPostId] = imageData;
  }

  Future<void> deleteFoodPostImage(String foodPostId) async {
    final storageRef = _storage.ref("foodPostImages").child("$foodPostId.jpg");
    await storageRef.delete();
  }

  Future<Uint8List?> getUserProfileImage(String userId) async {
    if (_userProfileImageCache.containsKey(userId)) {
      return _userProfileImageCache[userId];
    }

    final storageRef = _storage.ref("userProfileImages").child("$userId.jpg");
    final imageData = await storageRef.getData(_maxSize);

    if (imageData != null) _userProfileImageCache[userId] = imageData;
    return imageData;
  }

  Future<void> setUserProfileImage(String userId, Uint8List imageData) async {
    final storageRef = _storage.ref("userProfileImages").child("$userId.jpg");
    await storageRef.putData(
      imageData,
      SettableMetadata(contentType: "image/jpeg"),
    );

    _userProfileImageCache[userId] = imageData;
  }

  Future<Uint8List?> getGroupImage(String groupId) async {
    if (_groupImageCache.containsKey(groupId)) {
      return _groupImageCache[groupId];
    }

    final storageRef = _storage.ref("groupImages").child("$groupId.jpg");
    final imageData = await storageRef.getData(_maxSize);

    if (imageData != null) _groupImageCache[groupId] = imageData;
    return imageData;
  }
}
