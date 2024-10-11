import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:family_locator/utils/location_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This field stores the userId(DeviceId) as key and location as values
  RxMap<String, LatLng> userLocations = <String, LatLng>{}.obs;
  RxMap<String, String> userNames = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  fetchLocations() async {
    List<String> roomIds = await getAllMembersInRooms();
    // AppConstants.log.e(roomIds);

    if (roomIds.isNotEmpty) {
      _firestore
          .collection("anonymous")
          .where(FieldPath.documentId, whereIn: roomIds)
          .snapshots()
          .listen((roomSnapshot) {
        userLocations.clear(); // Clear previous locations
        for (var doc in roomSnapshot.docs) {
          final userId = doc.id;
          final usr = doc.get('usr');
          final currLoc = doc.get('currLoc'); // Get the currLoc string
          final location =
              LocationUtils.parseLocation(currLoc); // Parse the location string
          if (location != null) {
            userLocations[userId] = location; // Store the LatLng object
          }
          if (usr != null) {
            userNames[userId] = usr;
          }
        }
      });
    } else {
      userLocations.clear(); // Clear locations if there are no members
    }
  }

//  Get All Members from all Rooms (only those room in which user is the member).
  Future<List<String>> getAllMembersInRooms() async {
    // Step 1: Get the roomIds from the "anonymous" collection
    List<String> roomIds = (await _firestore
            .collection("anonymous")
            .doc(DeviceInfo.deviceId)
            .get())
        .get("roomId")
        .cast<String>(); // Cast to List<String> if necessary

    // Step 2: Create a set to store all unique member IDs (to avoid duplicates)
    Set<String> allMembers = {};

    // Step 3: Loop through each roomId and query the roomDetail collection
    for (String roomId in roomIds) {
      DocumentSnapshot roomSnapshot =
          await _firestore.collection("roomDetail").doc(roomId).get();

      if (roomSnapshot.exists) {
        // Step 4: Get the members field (assuming it's a List of Strings)
        List<String> members =
            List<String>.from(roomSnapshot.get("members") ?? []);

        // Step 5: Add all members to the set (ensures no duplicates)
        allMembers.addAll(members);
      }
    }

    // Step 6: Convert the set to a list and return it
    return allMembers.toList();
  }

   // to get the bounds of all users location
  LatLngBounds? get userLocationBounds {
    if (userLocations.isEmpty || userLocations.length < 2) return null;
    final points = userLocations.values.toList();
    return LatLngBounds.fromPoints(points);
  }
}
