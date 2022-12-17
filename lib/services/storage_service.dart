import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static const _maxSize = 5 * 1024 * 1024;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, Uint8List> _foodPostImageCache =
      {}; // food post ID -> image data

  Future<Uint8List?> getFoodPostImage(String foodPostId) async {
    if (_foodPostImageCache.containsKey(foodPostId)) {
      return _foodPostImageCache[foodPostId];
    }

    final storageRef = _storage.ref("foodPostImages").child("$foodPostId.jpg");
    final imageData = await storageRef.getData(_maxSize);

    if (imageData != null) {
      _foodPostImageCache[foodPostId] = imageData;
    }

    return imageData;
  }
}
