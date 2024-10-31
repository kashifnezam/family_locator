import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/firebase_api.dart';
import '../api/firebase_file_api.dart';
import '../utils/custom_alert.dart';
import '../utils/device_info.dart';
import '../utils/offline_data.dart';
import '../widgets/custom_widget.dart';
import '../pages/home.dart';

class MembersController extends GetxController {
  RxList<Map<String, dynamic>> membersMap = <Map<String, dynamic>>[].obs;
  RxString groupName = ''.obs;
  RxString user = ''.obs;
  RxBool isAdmin = false.obs;
  RxString dpImagePath = ''.obs;
  RxString finalDpImagePath = ''.obs;
  RxBool groupNameEdit = false.obs;
  RxBool isLoad = false.obs;
  RxBool isValid = true.obs;
  RxString isNotValidMsg = ''.obs;

  final TextEditingController groupNameController = TextEditingController();

  // Set members data and initialize controller values
  void setMembers(List<Map<String, dynamic>> newMembers) {
    membersMap.assignAll(newMembers);
    groupName.value = newMembers[0]['GroupName'];
    groupNameController.text = groupName.value;
    dpImagePath.value = newMembers[0]['dp'];
    finalDpImagePath.value = newMembers[0]['dp'];
  }

  // Update group name in both groupName observable and membersMap
  void updateGroupName(String newName) {
    groupName.value = newName;
    membersMap[0]['GroupName'] = newName;
  }

  // Remove a member at a specified index
  void removeMember(int index) {
    if (index > 0 && index < membersMap.length) {
      membersMap.removeAt(index);
    }
  }

  // Update admin status for a member
  void toggleAdminStatus(int index, bool isPromoting) {
    if (index > 0 && index < membersMap.length) {
      membersMap[index]['isAdmin'] = isPromoting;
    }
  }

  // Handle user group exit with confirmation and alert dialogs
  Future<int> exitGroup(BuildContext context) async {
    if (await CustomAlert.confirmAlert(context,
        "Are you sure you want to leave \"${membersMap[0]['GroupName']}\"?")) {
      if (context.mounted) CustomAlert.loadAlert(context, "Please wait...");

      try {
        final value =
            await FirebaseApi.exitGroup(membersMap[0]['roomId'], user.value);

        if (value == 0) {
          await FirebaseApi.userJoinLeft("left", membersMap[0]["roomId"],
              await OfflineData.getData("usr") ?? "");
          Get.offAll(() => Home());
          return 0;
        }
      } catch (e) {
        if (context.mounted) {
          CustomAlert.errorAlert(context, "An error occurred: $e");
        }
      } finally {
        if (context.mounted) {
          CustomAlert.dismissAlert(context);
        }
      }
    }
    return -1;
  }

  // Submit form and update group data accordingly
  Future<void> submitForm() async {
    isLoad.value = true;
    final groupNameInput = groupNameController.text.trim();

    if (_isValidGroupName(groupNameInput)) {
      await _updateGroupName(groupNameInput);
      await _updateGroupDpImage();
    } else {
      isValid.value = false;
      isNotValidMsg.value =
          "Please enter a valid group name (3-15 alphanumeric characters).";
    }

    isLoad.value = false;
  }

  // Validate group name length and content
  bool _isValidGroupName(String name) {
    return name.length >= 3 && name.length <= 15 && name != groupName.value;
  }

  // Update group name in Firebase and locally if valid
  Future<void> _updateGroupName(String name) async {
    if (name != groupName.value) {
      int status =
          await FirebaseApi.updateRoomName(name, membersMap[0]["roomId"]);
      if (status == 0) {
        groupName.value = name;
      } else {
        isValid.value = false;
        isNotValidMsg.value = "Error updating group name.";
      }
    }
  }

  // Update group profile image in Firebase and locally
  Future<void> _updateGroupDpImage() async {
    if (dpImagePath.value.isNotEmpty &&
        dpImagePath.value != finalDpImagePath.value) {
      String url = await FirebaseFileApi.uploadImage(
          "${DeviceInfo.deviceId}+${groupName.value}", dpImagePath.value, "dp");

      if (url.isNotEmpty) {
        int result = await FirebaseFileApi.updateImagePath(
            "roomDetail", membersMap[0]["roomId"], url, "dp");
        if (result == 0) {
          dpImagePath.value = url;
          finalDpImagePath.value = url;
          CustomWidget.confirmDialogue(
            title: "Room Updated Successfully",
            content: "Please restart the app to see changes.",
            isCancel: false,
          );
        } else {
          dpImagePath.value = "";
        }
      }
    }
  }
}
