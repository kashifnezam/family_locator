import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/api/firebase_file_api.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../utils/offline_data.dart';

class ProfileController extends GetxController {
  RxString dpImagePath = "".obs;
  RxString finalDpImagePath = "".obs;
  RxBool userNameEdit = false.obs;
  RxBool isLoad = false.obs;
  final userNameController = TextEditingController();
  final username = "".obs;
  final isValid = true.obs;
  final RxString isNotValidMsg = "".obs;

  @override
  void onInit() {
    super.onInit();
    getUserNameDP();
  }

  Future<void> getUserNameDP() async {
    username.value = (await OfflineData.getData("usr")) ?? "Unknown";

    userNameController.text = username.value;
    dpImagePath.value =
        await FirebaseApi.getDP("anonymous", DeviceInfo.deviceId!);
    finalDpImagePath.value = dpImagePath.value;
  }

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

  Future<void> submitForm() async {
    isLoad.value = true;
    String usn = userNameController.text.trim();
    if (usn != username.value) {
      if ((usn.length < 3 || usn.length > 15) &&
          (usn.isEmpty || usn != username.value)) {
        Get.snackbar(
          backgroundColor: Colors.red.shade100,
          'Error',
          'Please enter valid Alphanumeric username not more than 15 letters',
        );
        return;
      } else {
        String username = usn.toLowerCase();
        validateUsername(username);
        if (isValid.value) {
          int sts = await FirebaseApi.checkUsernameExists(username);
          if (sts == 1) {
            OfflineData.setData(
                "usr", usn, true); // Proceed with the valid username
            Get.snackbar(
              username,
              "username valid for 1 week, please LOGIN for permanent username",
              backgroundColor: Colors.greenAccent,
            );
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

    if (dpImagePath.value.isNotEmpty &&
        dpImagePath.value != finalDpImagePath.value) {
      String url = await FirebaseFileApi.uploadImage(
          "${DeviceInfo.deviceId}+${username.value}",
          dpImagePath.value,
          "userDp");
      if (url.isNotEmpty) {
        int res = await FirebaseFileApi.updateImagePath(
            "anonymous", DeviceInfo.deviceId!, url, "dp");
        if (res == 0) {
          dpImagePath.value = url;
          finalDpImagePath.value = url;
        } else {
          dpImagePath.value = "";
        }
      } else {}
    }
    isLoad.value = false;
  }
}
