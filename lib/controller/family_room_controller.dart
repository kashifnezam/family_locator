import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:get/get.dart';

import '../api/firebase_api.dart';
import '../utils/device_info.dart';

class FamilyRoomController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<dynamic, dynamic>> roomList = <Map<dynamic, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    getRoomDetails();
    Timer(const Duration(seconds: 6), () {
      AppConstants.log.w(roomList);
    });
  }

  void getRoomDetails() async {
    try {
      List<String> roomIds = await FirebaseApi.getRoomMembers(
          DeviceInfo.deviceId!, "anonymous", "roomId");
      for (String roomNo in roomIds) {
        DocumentSnapshot<Map<String, dynamic>> roomDoc =
            await _firestore.collection("roomDetail").doc(roomNo).get();
        Map<String, String> field = {};
        if (roomDoc.exists) {
          field["roomNo"] = roomNo;
          field["name"] = roomDoc.data()!.containsKey("roomName")
              ? roomDoc.get("roomName")
              : "Unknown";
          field["dp"] = roomDoc.data()!.containsKey("dp")
              ? roomDoc.get("dp")
              : "https://bit.ly/4dQVSet";
          field["owner"] = roomDoc.get("owner");
        }
        roomList.add(field);
      }
    } catch (e) {
      CustomWidget.confirmDialogue(
        title: "Somethinbg went wrong",
        content: "Failed to get rooms info, $e",
        isCancel: false,
      );
    }
  }
}
