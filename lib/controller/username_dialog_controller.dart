import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/offline_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
    AppConstants.log.i(isValid.value);
    if (isValid.value) {
      if (await FirebaseApi.checkUsernameExists(username)) {
        OfflineData.setData(
            "usr", usernameController.text, true); // Proceed with the valid username
        Get.back(result: usernameController.text); // Return the username
        Get.snackbar(
            username, "username set for 1 week, login for permanent username");
      } else {
        isValid.value = false;
        isNotValidMsg.value = "username already exists!";
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
