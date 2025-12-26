import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/api/firebase_api.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:family_room/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../utils/offline_data.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxMap<String, LatLng> userLocations = <String, LatLng>{}.obs;
  RxMap<String, List<String>> userDetails = <String, List<String>>{}.obs;
  List<String> roomIds = [];
  final mapController = MapController();
  RxString dpImagePath = "".obs;
  RxString username = "Not Available".obs;
  RxString email = "Not Available".obs;

  @override
  void onInit() {
    super.onInit();
    getUserNameDP();
    fetchLocations();
  }

  fetchLocations() async {
    List<String> roomIds = await getAllMembersInRooms();

    if (roomIds.isNotEmpty) {
      _firestore
          .collection("user")
          .where(FieldPath.documentId, whereIn: roomIds)
          .snapshots()
          .listen((roomSnapshot) async {
        for (var doc in roomSnapshot.docs) {
          final data = doc.data(); // easier to reuse
          final userId = doc.id;

          // --- Handle location safely ---
          if (data.containsKey('currLoc') && data['currLoc'] != null) {
            final currLoc = data['currLoc'];
            final location = LocationUtils.parseLocation(currLoc);

            if (location != null) {
              // Update only if location has changed
              if (userLocations[userId] != location) {
                userLocations[userId] = location;
              }
            }
          } else {
            // Optional: you can decide what to do if no currLoc
            // e.g. remove from map:
            // userLocations.remove(userId);
          }

          // --- Update user details ---
          final dp = await FirebaseApi.getDP("user", userId);

          // usr name might also be missing, so be defensive
          final userName = data['usr'] ?? '';

          List<String> usr = [dp, userName];

          if (data.containsKey("roomId") && data["roomId"] != null) {
            usr.addAll(getCommonGroup(List<String>.from(data["roomId"])));
          }

          userDetails[userId] = usr;
        }
      });
    } else {
      userLocations.clear(); // Clear all locations if no room members are found
    }
  }

  Future<List<String>> getAllMembersInRooms() async {
    roomIds = await FirebaseApi.getRoomMembers(
      DeviceInfo.userUID!,
      "user",
      "roomId",
    );

    Set<String> allMembers = {};
    for (String roomId in roomIds) {
      List<String> members =
          await FirebaseApi.getRoomMembers(roomId, "roomDetail", "members");
      allMembers.addAll(members);
    }

    return allMembers.toList();
  }

  LatLngBounds? get userLocationBounds {
    if (userLocations.isEmpty || userLocations.length < 2) return null;
    final points = userLocations.values.toList();
    return LatLngBounds.fromPoints(points);
  }

  void selectLocation(LatLng? location) {
    if (location != null) {
      mapController.move(location, 16.0);
    } else {
      fitMapToBounds();
    }
  }

  List<String> getCommonGroup(List<String> group) {
    return Set<String>.from(group)
        .intersection(Set<String>.from(roomIds))
        .toList();
  }

  fitMapToBounds() {
    try {
      if (userLocations.isNotEmpty && userLocations.length > 1) {
        final bounds = LatLngBounds.fromPoints(userLocations.values.toList());
        mapController.fitCamera(CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
        ));
      }
    } catch (e) {
      AppConstants.log.e(e);
    }
  }

  getUserNameDP() async {
    username.value = userInfo?["usr"] ?? "Not Available";
    dpImagePath.value = userInfo?["dp"] ?? "NA";
    email.value = userInfo?["email"] ?? "NA";

  }
}
