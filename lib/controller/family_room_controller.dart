import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:get/get.dart';
import '../api/firebase_api.dart';
import '../utils/device_info.dart';

class FamilyRoomController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> roomList = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    getRoomDetails();
  }

  void getRoomDetails() async {
    try {
      // Fetch room IDs for the current user
      List<String> roomIds = await FirebaseApi.getRoomMembers(
          DeviceInfo.deviceId!, "anonymous", "roomId");

      // Listen for changes in the roomDetail collection
      _firestore.collection("roomDetail").where(FieldPath.documentId, whereIn: roomIds).snapshots().listen((snapshot) {
        // Clear previous room details
        roomList.clear();

        // Process each document in the snapshot
        for (var doc in snapshot.docs) {
          Map<String, dynamic> field = {
            "roomNo": doc.id,
            "name": doc.data().containsKey("roomName") ? doc.data()["roomName"] : "Unknown",
            "dp": doc.data().containsKey("dp") ? doc.data()["dp"] : "",
            "owner": doc.data()["owner"]
          };

          roomList.add(field);
        }
      });
    } catch (e) {
      CustomWidget.confirmDialogue(
        title: "Something went wrong",
        content: "Failed to get rooms info: $e",
        isCancel: false,
      );
    }
  }
}
