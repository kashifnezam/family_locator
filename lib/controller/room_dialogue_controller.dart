import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RoomDialogController extends GetxController {
  final nameController = TextEditingController();
  final roomController = TextEditingController();
  final isCreatingRoom = true.obs;

  void toggleMode() {
    isCreatingRoom.toggle();
    nameController.clear();
    roomController.clear();
  }

  void submitForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }
    if (roomController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a room number');
      return;
    }
    if (roomController.text.length < 6) {
      Get.snackbar('Error', 'Room number must be at least 6 characters');
      return;
    }

    // Process the form
    String action = isCreatingRoom.value ? 'Created' : 'Joined';
    Get.back(); // Close the dialog
    Get.snackbar(
      '$action Room',
      'Name: ${nameController.text}, Room: ${roomController.text}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    roomController.dispose();
    super.onClose();
  }
}
