import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:family_locator/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This field stores the userId(DeviceId) as key and location as values
  RxMap<String, LatLng> userLocations = <String, LatLng>{}.obs;
  RxMap<String, List<String>> userDetails = <String, List<String>>{}.obs;
  List<String> roomIds = [];
  final mapController = MapController();

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
          List<String> usr = [];
          usr.add(doc.get('usr'));
          if (doc.data().containsKey("roomId")) {
            usr.addAll(getCommonGroup(doc.get('roomId').cast<String>()));
          }
          final userId = doc.id;

          final currLoc = doc.get('currLoc'); // Get the currLoc string
          final location =
              LocationUtils.parseLocation(currLoc); // Parse the location string
          if (location != null) {
            userLocations[userId] = location; // Store the LatLng object
          }
          userDetails[userId] = usr;
        }
      });
    } else {
      userLocations.clear(); // Clear locations if there are no members
    }
  }

//  Get All Members from all Rooms (only those room in which user is the member).
  Future<List<String>> getAllMembersInRooms() async {
    roomIds = await FirebaseApi.getRoomMembers(
        DeviceInfo.deviceId!, "anonymous", "roomId");

    // Step 2: Create a set to store all unique member IDs (to avoid duplicates)
    Set<String> allMembers = {};

    // Step 3: Loop through each roomId and query the roomDetail collection
    for (String roomId in roomIds) {
      List<String> members =
          await FirebaseApi.getRoomMembers(roomId, "roomDetail", "members");
      allMembers.addAll(members);
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

// This method is used to zoom in the location when tab on user location on map
  void selectLocation(LatLng? location) {
    if (location != null) {
      mapController.move(location, 16.0);
    } else {
      fitMapToBounds();
    }
  }

  // Common Group extraction
  List<String> getCommonGroup(List<String> group) {
    // Find the intersection with the second list
    return Set<String>.from(group)
        .intersection(Set<String>.from(roomIds))
        .toList();
  }

  void fitMapToBounds() {
    if (userLocations.isNotEmpty && userLocations.length > 1) {
      final bounds = LatLngBounds.fromPoints(userLocations.values.toList());
      mapController.fitCamera(CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0)));
    }
  }
}
