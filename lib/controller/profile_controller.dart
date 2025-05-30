import 'package:family_room/api/firebase_api.dart';
import 'package:family_room/api/firebase_file_api.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/offline_data.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  RxString dpImagePath = "".obs;
  RxString finalDpImagePath = "".obs;
  RxBool userNameEdit = false.obs;
  RxBool isLoad = false.obs;
  final userNameController = TextEditingController();
  final username = "".obs;
  final isValid = true.obs;
  final RxString isNotValidMsg = "".obs;

  // Here using Home controller to update edit dp and username
  final HomeController homeController = Get.put(HomeController());
  OfflineData offlineData = OfflineData();
  @override
  void onInit() {
    super.onInit();
    getUserNameDP();
  }

  Future<void> getUserNameDP() async {
    username.value = userInfo?["usr"] ?? "Not Available";

    userNameController.text = username.value;
    dpImagePath.value = userInfo?["dp"] ?? "NA";
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
      String usr = usn.toLowerCase();
      validateUsername(usr);
      if (isValid.value) {
        int sts = await FirebaseApi.checkUsernameExists(usr);
        if (sts == 1) {
          offlineData.refreshUserData(DeviceInfo.deviceId);
          homeController.username.value = usr;
          username.value = usr;
          Get.snackbar(
            usr,
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
          offlineData.refreshUserData(DeviceInfo.deviceId);
          homeController.dpImagePath.value = url;
        } else {
          dpImagePath.value = "";
        }
      } else {}
    }
    isLoad.value = false;
  }
}
