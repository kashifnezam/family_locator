import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/api/firebase_api.dart';
import 'package:family_room/api/firebase_file_api.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/offline_data.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  RxString dpImagePath = "".obs;
  RxString finalDpImagePath = "".obs;
  RxBool userNameEdit = false.obs;
  RxBool isLoading = false.obs;
  final username = "".obs;
  final isValid = true.obs;
  final RxString isNotValidMsg = "".obs;

  // Observable variables
  var fullName = ''.obs;
  var email = ''.obs;
  var mobile = ''.obs;
  var isEditing = false.obs;

  final userNameController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  // Here using Home controller to update edit dp and username
  final HomeController homeController = Get.put(HomeController());
  OfflineData offlineData = OfflineData();

  @override
  void onInit() {
    super.onInit();
    getUserProfileData();
  }

  Future<void> getUserProfileData() async {
    username.value = userInfo?["usr"] ?? "";
    email.value = userInfo?["email"] ?? "";
    mobile.value = userInfo?["mobile"] ?? "";
    fullName.value = userInfo?["fullName"] ?? "";
    userNameController.text = username.value;
    dpImagePath.value = userInfo?["dp"] ?? "NA";
    finalDpImagePath.value = dpImagePath.value;
  }

  void validateUsername(String? username) {
    // Reset validation state
    isValid.value = false;
    isNotValidMsg.value = '';

    if(username == null){
      isValid.value = true;
      isNotValidMsg.value = "username can't be empty";
      return;
    }
    // Trim whitespace from both ends first
    final trimmedUsername = username.trim();

    // 1. Check for leading/trailing whitespace (if input wasn't trimmed earlier)
    if (username != trimmedUsername) {
      isNotValidMsg.value = "No leading or trailing spaces allowed";
      return;
    }

    // 2. Check length (4-10 characters)
    if (trimmedUsername.length < 4 || trimmedUsername.length > 10) {
      isNotValidMsg.value = "Username must be 4-10 characters long";
      return;
    }

    // 3. Check for any whitespace (including middle of string)
    if (trimmedUsername.contains(' ')) {
      isNotValidMsg.value = "No spaces allowed in username";
      return;
    }

    // 4. Check for starting with a number
    if (RegExp(r'^[0-9]').hasMatch(trimmedUsername)) {
      isNotValidMsg.value = "Cannot start with a number";
      return;
    }

    // 5. Check for special characters (only alphanumeric allowed)
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmedUsername)) {
      isNotValidMsg.value =
          "Only letters and numbers allowed (no special chars)";
      return;
    }

    // If all checks pass
    isValid.value = true;
  }

  Future<void> submitForm() async {
    isLoading.value = true;

    try {
      // 1. Handle username update if changed
      final String newUsername = userNameController.text.trim().toLowerCase();
      validateUsername(newUsername);

      if (newUsername != username.value) {
        final int usernameStatus =
            await FirebaseApi.checkUsernameExists(newUsername);
        if (usernameStatus != 1) {
          _handleUsernameError(usernameStatus);
          isLoading.value = false;
          return;
        }

        await _updateUsername(newUsername);
      }

      // 2. Handle profile picture update if changed
      if (dpImagePath.value.isNotEmpty &&
          dpImagePath.value != finalDpImagePath.value) {
        await _updateProfilePicture();
      }

      // 3. Update other profile fields
      await _updateProfileFields();

      // 4. Refresh data and show success
      await offlineData.refreshUserData(DeviceInfo.userUID);
      _updateLocalControllers();
      CustomAlert.successAlert("Profile updated successfully");
    } catch (e) {
      AppConstants.log.e('Error updating profile: $e');
      CustomAlert.errorAlert("Failed to update profile. Please try again.");
    } finally {
      isLoading.value = false;
      isEditing.value = false;
    }
  }

// Helper methods for submitForm()

  void _handleUsernameError(int status) {
    isValid.value = false;
    isNotValidMsg.value = status == 0
        ? "Username already exists!"
        : status == 2
            ? "Device ID not found!"
            : "Something went wrong";
  }

  Future<void> _updateUsername(String newUsername) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(DeviceInfo.userUID)
        .set({'usr': newUsername}, SetOptions(merge: true));

    username.value = newUsername;
    homeController.username.value = newUsername;
  }

  Future<void> _updateProfilePicture() async {
    final String url = await FirebaseFileApi.uploadImage(
        "${DeviceInfo.userUID}+${username.value}", dpImagePath.value, "userDp");

    if (url.isEmpty) throw Exception("Failed to upload image");

    final int res = await FirebaseFileApi.updateImagePath(
        "user", DeviceInfo.userUID!, url, "dp");

    if (res != 0) throw Exception("Failed to update image path");

    dpImagePath.value = url;
    finalDpImagePath.value = url;
    homeController.dpImagePath.value = url;
  }

  Future<void> _updateProfileFields() async {
    final Map<String, dynamic> updates = {
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'mobile': mobileController.text.trim(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('user')
        .doc(DeviceInfo.userUID)
        .set(updates, SetOptions(merge: true));

    // Update local observables
    fullName.value = updates['fullName'];
    email.value = updates['email'];
    mobile.value = updates['mobile'];
  }

  void _updateLocalControllers() {
    // Update controllers to reflect new values
    userNameController.text = username.value;
    fullNameController.text = fullName.value;
    emailController.text = email.value;
    mobileController.text = mobile.value;

    // Update home controller if needed
    homeController.email.value = email.value;
  }

  void startEditing() {
    isEditing.value = true;
    // Initialize controllers with current values
    fullNameController.text = fullName.value;
    emailController.text = email.value;
    mobileController.text = mobile.value;
  }

  Future<void> cancelEditing() async {
    isEditing.value = false;

    // Reset text fields
    getUserProfileData();
    // Reset validation state
    isValid.value = true;
    isNotValidMsg.value = '';

    // Close any open keyboards/dialogs
    Get.focusScope?.unfocus();
  }
}
