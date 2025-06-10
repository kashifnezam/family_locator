import 'package:family_room/api/firebase_api.dart';
import 'package:family_room/utils/offline_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/device_info.dart';

class UsernameDialogController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final isValid = true.obs;
  final RxString isNotValidMsg = "".obs;

  void validateUsername(String username) {
    // Combined validation checks
    if (username.length < 4 || username.length > 10) {
      isNotValidMsg.value = "Username length must be 4-10";
    } else if (RegExp(r'^[0-9]').hasMatch(username) ||
        !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
      isNotValidMsg.value =
          "Don't use special characters or start with a number";
    } else {
      isValid.value = true;
      return;
    }

    isValid.value = false;
  }

  Future<void> submit() async {
    String username = usernameController.text.trim().toLowerCase();
    validateUsername(username);
    if (isValid.value) {
      int sts = await FirebaseApi.checkUsernameExists(username);
      if (sts == 1) {
        OfflineData offlineData = OfflineData();
        offlineData.refreshUserData(
            DeviceInfo.userUID); // Proceed with the valid username
        Get.back();
        // Get.snackbar(
        //   username,
        //   "username valid for 1 week, please LOGIN for permanent username",
        //   backgroundColor: Colors.greenAccent,
        // );
      } else if (sts == 0) {
        isValid.value = false;
        isNotValidMsg.value = "username already exists!";
      } else if (sts == 2) {
        isValid.value = false;
        isNotValidMsg.value = "Device ID not found!";
      } else {
        isValid.value = false;
        isNotValidMsg.value = "Something went wrong";
      }
    }
  }
}
