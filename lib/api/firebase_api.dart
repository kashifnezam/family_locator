import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/models/anonymous_model.dart';
import 'package:family_locator/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/constants.dart';

class FirebaseApi {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Fetch data from Firestore
  static Future<List<UserModel>> fetchData(String col) async {
    List<UserModel> groupMembers = [];
    try {
      CollectionReference membersCollection = _firestore.collection(col);

      QuerySnapshot snapshot = await membersCollection.get();

      groupMembers = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppConstants.log.e("Error fetching group members", error: e.toString());
    }
    return groupMembers;
  }

  // Fetch a specific document by ID within a specific collection
  static Future<UserModel?> fetchDocumentById(String col, String userId) async {
    try {
      DocumentReference documentReference =
          _firestore.collection(col).doc(userId);

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        return UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>);
      } else {
        AppConstants.log
            .w("Document with ID $userId does not exist in collection $col.");
        return null; // Document does not exist
      }
    } catch (e) {
      AppConstants.log.e(
          "Error fetching document with ID $userId from collection $col",
          error: e.toString());
      return null; // Return null in case of error
    }
  }

  // Add data to Firestore
  static Future<bool> addData(String col, UserModel user) async {
    try {
      CollectionReference membersCollection = _firestore.collection(col);

      await membersCollection.add(user.toJson());
      AppConstants.log.i("User added successfully to $col.");
      return true; // Operation successful
    } catch (e) {
      AppConstants.log.e("Error adding group member", error: e.toString());
      return false; // Operation failed
    }
  }

  static Future<bool> addDataToDocument(
      String col, String docId, UserModel user) async {
    user.added = DateTime.now().toString();
    user.email = FirebaseAuth.instance.currentUser!.email.toString();
    try {
      // Reference to the specific document
      DocumentReference documentReference =
          _firestore.collection(col).doc(docId);

      // Set the data in the document
      await documentReference.set(user.toJson());
      AppConstants.log.i(
          "User data added successfully to document $docId in collection $col.");
      return true; // Operation successful
    } catch (e) {
      AppConstants.log.e(
          "Error adding user data to document $docId in collection $col",
          error: e.toString());
      return false; // Operation failed
    }
  }

  // Update data in Firestore
  static Future<bool> updateData(
      String col, String docId, UserModel updatedUser) async {
    try {
      DocumentReference memberDocument = _firestore.collection(col).doc(docId);

      await memberDocument.update(updatedUser.toJson());
      AppConstants.log.i("User updated successfully in $col.");
      return true; // Operation successful
    } catch (e) {
      AppConstants.log.e("Error updating group member", error: e.toString());
      return false; // Operation failed
    }
  }

  //For anonymous user
  static Future<bool> addDataIfNotExists(
      String collection, String documentId, AnonymousModel data) async {
    try {
      data.added = DateTime.now().toString();
      // Reference to the document
      DocumentReference documentReference =
          _firestore.collection(collection).doc(documentId);

      // Check if the document exists
      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // Document already exists, do not overwrite
        AppConstants.log.e(
            'Document with ID $documentId already exists. Data will not be overwritten.');
        return false; // Indicate that the document already exists
      } else {
        // Document does not exist, add the data
        await documentReference.set(data);
        AppConstants.log.i(
            'Data added successfully to document $documentId in collection $collection.');
        return true; // Indicate that the data was added successfully
      }
    } catch (e) {
      AppConstants.log.e('Error adding data: $e');
      return false; // Indicate that there was an error
    }
  }
}
