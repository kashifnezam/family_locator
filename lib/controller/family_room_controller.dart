import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:get/get.dart';
import '../utils/device_info.dart';

class FamilyRoomController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = true.obs;
  RxList<Map<String, dynamic>> roomList = <Map<String, dynamic>>[].obs;
  RxList<String> roomIds = <String>[].obs; // Observable list for room IDs

  @override
  void onInit() {
    super.onInit();
    listenToRoomMembership(); // Start listening to room membership changes
  }

  void listenToRoomMembership() {
    // Listen for changes in the user's room memberships
    _firestore
        .collection(
            'anonymous') // Assuming there's a collection tracking user rooms
        .doc(DeviceInfo.deviceId!) // Document ID based on device ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        List<String> newRoomIds =
            List<String>.from(snapshot.data()!['roomId'] ?? []);

        // Update the roomIds observable list
        roomIds.value = newRoomIds;

        // Fetch and update room details whenever room IDs change
        getRoomDetails(newRoomIds);
      }
    });
    Timer(
      Duration(seconds: 1),
      () => isLoading.value = false,
    );
  }

  Future<void> getRoomDetails(List<String> newRoomIds) async {
    try {
      // Listen for changes in the roomDetail collection based on updated room IDs
      if (newRoomIds.isNotEmpty) {
        _firestore
            .collection("roomDetail")
            .where(FieldPath.documentId, whereIn: newRoomIds)
            .snapshots()
            .listen((snapshot) async {
          // Update roomList with new data
          roomList.value = await Future.wait(snapshot.docs.map((doc) async {
            String lastMessage = await getLastMessage(doc.id);
            return {
              "roomNo": doc.id,
              "name": doc.data().containsKey("roomName")
                  ? doc.data()["roomName"]
                  : "Unknown",
              "dp": doc.data().containsKey("dp") ? doc.data()["dp"] : "",
              "owner": doc.data()["owner"],
              "msg": lastMessage,
            };
          }));

          // Set up listeners for real-time updates on messages
          for (var doc in snapshot.docs) {
            listenToMessages(doc.id);
          }
        });
      }
    } catch (e) {
      CustomWidget.confirmDialogue(
        title: "Error",
        content: "Failed to get rooms info: ${e.toString()}",
        isCancel: false,
      );
    }
  }

  Future<void> listenToMessages(String roomId) async {
    _firestore
        .collection('chatrooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        String lastMessage = snapshot.docs.first.get("text") as String;

        // Update the corresponding room's last message
        int index = roomList.indexWhere((room) => room['roomNo'] == roomId);
        if (index != -1) {
          roomList[index]['msg'] = lastMessage; // Update last message
          roomList.refresh(); // Refresh to notify listeners
        }
      }
    });
  }

  Future<String> getLastMessage(String roomId) async {
    final snapshot = await _firestore
        .collection('chatrooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty
        ? snapshot.docs.first.get("text") as String
        : "";
  }
}
