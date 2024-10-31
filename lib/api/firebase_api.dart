import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/models/anonymous_model.dart';
import 'package:family_locator/models/user_model.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:family_locator/utils/location_utils.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/offline_data.dart';

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

  static Future<void> updateLocation(String loc, String id) async {
    _firestore
        .collection("anonymous")
        .doc(id)
        .set({'currLoc': loc}, SetOptions(merge: true));
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
      await documentReference.set(user.toJson(), SetOptions(merge: true));
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

      await memberDocument.set(updatedUser.toJson(), SetOptions(merge: true));
      AppConstants.log.i("User updated successfully in $col.");
      return true; // Operation successful
    } catch (e) {
      AppConstants.log.e("Error updating group member", error: e.toString());
      return false; // Operation failed
    }
  }

  //For anonymous user
  static Future<bool> addAnonymousData(
      String collection, String documentId, AnonymousModel data) async {
    try {
      data.added = DateTime.now().toString();
      // Reference to the document
      DocumentReference documentReference =
          _firestore.collection(collection).doc(documentId);

      await documentReference.set(data.toJson(), SetOptions(merge: true));
      AppConstants.log.i(
          'Data added successfully to document $documentId in collection $collection.\n${data.toJson()}');
      return true; // Indicate that the data was added successfully
    } catch (e) {
      AppConstants.log.e('Error adding data: $e');
      return false; // Indicate that there was an error
    }
  }

  /// Check whether the document exists or not
  static Future<bool> isDocumentExists(
      String collection, String documentId) async {
    DocumentReference documentReference =
        _firestore.collection(collection).doc(documentId);

    // Check if the document exists
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot.exists;
  }

  /// Room Number Add for the group
  static Future<int> createRoom(
      String deviceId, String roomId, String name) async {
    if (await isDocumentExists("roomDetail", roomId)) {
      AppConstants.log.e("Room with this id already Exists");
      return 0;
    }
    try {
      await _firestore.collection('anonymous').doc(deviceId).set({
        'roomId': FieldValue.arrayUnion([roomId]),
      }, SetOptions(merge: true));
      await _firestore.collection('roomDetail').doc(roomId).set({
        'members': FieldValue.arrayUnion([deviceId]),
        'roomName': name,
        "owner": deviceId,
        "created": DateTime.now().toString()
      }, SetOptions(merge: true));
      AppConstants.log.i('Room number added successfully');
      return 1;
    } catch (e) {
      AppConstants.log.e('Error adding room number: $e');
      return -1;
    }
  }

  static Future<int> roomJoin(String deviceId, String roomId) async {
    if (!await isDocumentExists("roomDetail", roomId)) {
      AppConstants.log.e("Room with this id does not Exist");
      return 0;
    }
    List<String> members =
        await getRoomMembers(roomId, "roomDetail", "members");
    if (!members.contains(deviceId)) {
      List<String> pending =
          await getRoomMembers(roomId, "roomDetail", "pending");
      if (!pending.contains(deviceId)) {
        modifyDeviceInCollection(
            "roomDetail", roomId, deviceId, "pending", true);
      } else {
        return -3;
      }
      return -2;
    }
    return 1;
  }

  static Future<void> userJoinLeft(String status, String roomId, String userId) async {
    final message = MessageModel(
      sender: 'System', // System message to indicate a user joined
      text: status == "joined" ?
      '${await OfflineData.getData("usr")} added => $userId'
          : "$userId left the room",
      timestamp: Timestamp.now(),
    );

    // Send the message to Firestore
    await _firestore
        .collection('chatrooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) async {
        await updateLocation(location.toString(), DeviceInfo.deviceId!);
      },
    );
  }

  /// Checks if the given username is already used in the 'anonymous' collection.
  static Future<int> checkUsernameExists(String username) async {
    try {
      // Query the 'anonymous' collection to check if the username exists
      QuerySnapshot querySnapshot = await _firestore
          .collection('anonymous')
          .where('usr', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Check if DeviceInfo.deviceId is available
        String? deviceId = DeviceInfo.deviceId;
        if (deviceId == null) {
          AppConstants.log.e('Device ID is not available.');
          return 2; // Fail gracefully if deviceId is null
        }

        // If no such username, update the 'usr' field with the new username
        await FirebaseFirestore.instance
            .collection('anonymous')
            .doc(deviceId)
            .set({
          'usr': username,
        }, SetOptions(merge: true));
      }

      // Return true if username does not exist, false otherwise
      return querySnapshot.docs.isEmpty ? 1 : 0;
    } catch (e) {
      AppConstants.log.e('Error checking username availability: $e');
      return 3; // Indicate failure
    }
  }

  // Method to get the list of members for a specific roomId
  static Future<List<String>> getRoomMembers(
      String roomId, String collectionName, String fieldName) async {
    try {
      // Fetch the room details document from Firestore
      DocumentSnapshot roomDoc =
          await _firestore.collection(collectionName).doc(roomId).get();

      // Check if the room document exists
      if (!roomDoc.exists) {
        AppConstants.log.e("Room does not exist");
        return [];
      }

      // Get the document data as a map
      Map<String, dynamic>? roomData = roomDoc.data() as Map<String, dynamic>?;

      // Check if the room data contains the requested field
      if (roomData == null || !roomData.containsKey(fieldName)) {
        AppConstants.log.e("Field '$fieldName' does not exist in the document");
        return [];
      }

      // Extract the members list from the room document
      List<dynamic> members = roomData[fieldName] ?? [];

      // Ensure the members list contains strings and return it
      List<String> memberList = members.cast<String>();

      return memberList;
    } catch (e) {
      // Handle any errors during the Firestore operation
      AppConstants.log.e("Error retrieving room members: $e");
      return [];
    }
  }

  // Add confirm, pending users
  static Future<void> modifyDeviceInCollection(String collectionName,
      String docName, String deviceId, String fieldName, bool shouldAdd) async {
    try {
      // Determine the FieldValue operation based on the shouldAdd flag
      var operation = shouldAdd
          ? FieldValue.arrayUnion([deviceId]) // Add device ID
          : FieldValue.arrayRemove([deviceId]); // Remove device ID

      // Perform the Firestore update
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docName)
          .set({
        fieldName: operation,
      }, SetOptions(merge: true));

      AppConstants.log.i(shouldAdd
          ? 'Device ID added successfully'
          : 'Device ID removed successfully');
    } catch (e) {
      AppConstants.log.e('Error modifying device ID: $e');
    }
  }

  // get Room Name
  static Future<String> getRoomName(String roomNo) async {
    DocumentSnapshot roomDoc =
        await _firestore.collection("roomDetail").doc(roomNo).get();
    if (!roomDoc.exists) {
      AppConstants.log.e("Room Does not exist");
      return "Chat Room(Unknown)";
    }
    return roomDoc.get("roomName") ?? "Chat Room";
  }

  // Get Admin
  static Future<String> getOwner(String roomNo) async {
    DocumentSnapshot roomDoc =
        await _firestore.collection("roomDetail").doc(roomNo).get();
    if (!roomDoc.exists) {
      AppConstants.log.e("Room Does not exist");
      return "";
    }
    return roomDoc.get("owner") ?? "";
  }

  // Get DP
  static Future<String> getDP(String collection, String doc) async {
    DocumentSnapshot dpDoc =
        await _firestore.collection(collection).doc(doc).get();

    // Check if the document exists
    if (!dpDoc.exists) {
      AppConstants.log.e("Collection ($collection) does not exist");
      return "";
    }

    // Check if the 'dp' field exists in the document
    if (dpDoc.data() != null &&
        (dpDoc.data() as Map<String, dynamic>).containsKey('dp')) {
      return dpDoc.get('dp') ?? "";
    } else {
      AppConstants.log.e("DP field does not exist in document ($doc)");
      return "";
    }
  }

  static Future<int> exitGroup(String roomNo, String userId) async {
    try {
      // Run the update operations in a Firestore transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get references to the two documents
        DocumentReference roomDetailDoc =
            _firestore.collection("roomDetail").doc(roomNo);
        DocumentReference anonymousDoc =
            _firestore.collection("anonymous").doc(userId);

        // Remove the userId from the members list in roomDetail collection
        transaction.update(roomDetailDoc, {
          "members": FieldValue.arrayRemove([userId])
        });

        // Remove the roomNo from the roomIds list in the anonymous collection
        transaction.update(anonymousDoc, {
          "roomId": FieldValue.arrayRemove([roomNo])
        });
      });

      // Optional: Print success message
      AppConstants.log.i(
          "Successfully removed userId from room members and roomNo from user rooms.");
      return 0;
    } catch (e) {
      // Handle the error
      AppConstants.log.e("Error removing user from group: $e");
      CustomWidget.confirmDialogue(
          title: "Error",
          content: "Error removing user from group: $e",
          isCancel: false);
      return 1;
    }
  }

  // Update RoomName
  static updateRoomName(String roomName, String roomId) async {
    try {
      await _firestore.collection('roomDetail').doc(roomId).set({
        'roomName': roomName,
        "updated": DateTime.now().toString(),
      }, SetOptions(merge: true));
      AppConstants.log.i('Room Name updated successfully');
      return 0;
    } catch (e) {
      AppConstants.log.e('Error updating Room Name of $roomId');
      CustomWidget.confirmDialogue(
          title: "Error Updating Name",
          content:
              "Error occured while updating Room Name: $roomName of RoomId: $roomId");
    }
    return -1;
  }

  Future<Map<String, dynamic>?> getLastMessage(String roomId) async {
    try {
      // Query messages in the specified roomId, ordered by timestamp in descending order
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1) // Limit to the latest message
          .get();

      // Check if there's at least one document in the result
      if (snapshot.docs.isNotEmpty) {
        // Extract the data of the last message document
        return snapshot.docs.first.data();
      } else {
        // If no messages found, return null
        return null;
      }
    } catch (e) {
      AppConstants.log.e("Error fetching last message for room $roomId: $e");
      return null;
    }
  }
}
