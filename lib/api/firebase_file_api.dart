import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFileApi {
  // reference insance which will be used to upload file
  static final Reference ref = FirebaseStorage.instance.ref();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload Image on Firebase
  static uploadImage(String filename, String filePath, String field) async {
    try {
      Reference dir = ref.child("family_room/image/$field/$filename");
      await dir.putFile(File(filePath));
      String downloadUrl = await dir.getDownloadURL();
      AppConstants.log.i("File uploaded successfully");
      return downloadUrl;
    } catch (e) {
      AppConstants.log.e("Error while uploading file, $e");
      CustomWidget.confirmDialogue(
          title: "Something went wrong",
          content: "Error while uploading file, $e",
          isCancel: false);
    }
  }

  static updateImagePath(
      String collectionName, String doc, String url, String field) async {
    try {
      await _firestore.collection(collectionName).doc(doc).set({
        field: url,
      }, SetOptions(merge: true));
      AppConstants.log.i("File path updated successfully");
    } catch (e) {
      AppConstants.log.e("Error while updating file path, $e");
      CustomWidget.confirmDialogue(
          title: "Something went wrong",
          content: "Error while updating file path, $e",
          isCancel: false);
    }
  }
}
