import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

/// Take an image and a salfh ID.
/// Saves the image in a folder that has the salfhID as a name.
/// returns the image URL to store in cloud firestore.
class StorageFunctions {
  static Future<String> uploadImage({File imageFile, String salfhID}) async {
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${salfhID}/${DateTime.now().toString()}');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;

    String downloadUrl = await storageSnapshot.ref.getDownloadURL();

    if (uploadTask.isComplete) {
      return downloadUrl.toString();
    }
    return null;
  }
}
