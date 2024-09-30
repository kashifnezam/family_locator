import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../pages/chat_room.dart';
import '../utils/offline_data.dart';

class RoomDialogController extends GetxController {
  final nameController = TextEditingController();
  final roomController = TextEditingController();
  final isCreatingRoom = true.obs;
  final isLoading = false.obs; // Set to false initially

  void toggleMode() {
    isCreatingRoom.toggle();
    nameController.clear();
    roomController.clear();
  }

  Future<void> submitForm() async {
    if (roomController.text.isEmpty) {
      Get.snackbar(
        backgroundColor: Colors.red.shade100,
        'Error',
        'Please enter a room number',
      );
      return;
    }
    if (roomController.text.length < 6) {
      Get.snackbar(
        backgroundColor: Colors.red.shade100,
        'Error',
        'Room number must be at least 6 characters',
      );
      return;
    }

    // Start loading
    isLoading.value = true;

    try {
      // Process the form
      if (isCreatingRoom.value) {
        final response = await FirebaseApi.createRoom(
            DeviceInfo.deviceId!, roomController.text, nameController.text);

        if (response == 1) {
          String owner = await FirebaseApi.getOwner(
              roomController.text);
          Get.back();
          Get.snackbar(
            backgroundColor: Colors.green,
            'Created Room',
            'Name: ${await OfflineData.getData("usr")}, Room: ${roomController.text}',
            snackPosition: SnackPosition.TOP,
          );

          Get.to(
            () => ChatRoom(
              roomId: roomController.text,
              userId: DeviceInfo.deviceId.toString(),
              roomName: "Chat Room",
              owner: owner,
            ),
          );
        } else if (response == 0) {
          Get.snackbar(
            backgroundColor: Colors.red,
            'Room Already Exists',
            'Try changing Room no. or Join with Room: ${roomController.text}',
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar(
            backgroundColor: Colors.red,
            "Something went Wrong",
            "Restart your Application or Contact @technical.kashif123@gmail.com",
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        final response = await FirebaseApi.roomJoin(
            DeviceInfo.deviceId!, roomController.text);
        final name = await FirebaseApi.getRoomName(roomController.text);

        if (response == 1) {
          String owner = await FirebaseApi.getOwner(
              roomController.text);

          Get.back();
          Get.snackbar(
            backgroundColor: Colors.green,
            'Joined Room',
            'Name: ${await OfflineData.getData("usr")}, Room: ${roomController.text}',
            snackPosition: SnackPosition.TOP,
          );

          FirebaseApi.userJoinLeft("joined", roomController.text);
          Get.to(
            () => ChatRoom(
              roomId: roomController.text,
              userId: DeviceInfo.deviceId.toString(),
              roomName: name,
              owner: owner,
            ),
          );
        } else if (response == 0) {
          Get.snackbar(
            backgroundColor: Colors.red,
            'Room Does not Exist',
            'Try changing Room no. or Create Room: ${roomController.text}',
            snackPosition: SnackPosition.TOP,
          );
        } else if (response == -2) {
          Get.snackbar(
            backgroundColor: Colors.yellow,
            "Join Request Succesfully",
            "Request to join Room Id: ${roomController.text} is sent",
            snackPosition: SnackPosition.TOP,
          );
        } else if (response == -3) {
          Get.snackbar(
            backgroundColor: const Color.fromARGB(255, 60, 238, 197),
            "ALready Requested",
            "Please ask admin to accept your request",
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar(
            backgroundColor: Colors.red,
            "Something went Wrong",
            "Restart your Application or Contact @technical.kashif123@gmail.com",
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        backgroundColor: Colors.red,
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      // Stop loading
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    roomController.dispose();
    super.onClose();
  }
}
