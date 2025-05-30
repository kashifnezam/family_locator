import 'package:family_room/api/firebase_api.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/offline_data.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/firebase_file_api.dart';
import '../utils/device_info.dart';

class MembersController extends GetxController {
  var membersMap = <Map<String, dynamic>>[].obs; // Observable list of maps
  var groupName = ''.obs; // Observable for group name
  RxString user = ''.obs;
  RxBool isAdmin = false.obs;
  RxString dpImagePath = "".obs;
  RxString finalDpImagePath = "".obs;
  RxBool groupNameEdit = false.obs;
  RxBool isLoad = false.obs;
  final groupNameController = TextEditingController();
  final isValid = true.obs;
  final RxString isNotValidMsg = "".obs;

  void setMembers(List<Map<String, dynamic>> newMembers) {
    membersMap.assignAll(newMembers); // Update the members map
    groupName.value = newMembers.isNotEmpty
        ? newMembers[0]['GroupName']
        : ""; // Set initial group name
    groupNameController.text = groupName.value;
    dpImagePath.value = newMembers[0]['dp'];
    finalDpImagePath.value = newMembers[0]['dp'];
  }

  void updateGroupName(String newName) {
    groupName.value = newName; // Update group name
    membersMap[0]['GroupName'] = newName; // Update in the members map
  }

  Future<int> removeMember(int index) async {
    int res = -1;
    if (index > 0 && index < membersMap.length) {
      res = await FirebaseApi.removeMember(
          membersMap[0]["roomId"], membersMap[index]["id"]);
    }
    if (res == 0) {
      FirebaseApi.userJoinLeft(
          "remove", membersMap[0]["roomId"], membersMap[index]["name"]);
      membersMap.removeAt(index);
    }
    return res;
  }

  void promoteToAdmin(int index) {
    if (index > 0 && index < membersMap.length) {
      membersMap[index]['isAdmin'] = true; // Promote member to admin
    }
  }

  void discardAdmin(int index) {
    if (index > 0 && index < membersMap.length) {
      membersMap[index]['isAdmin'] = false; // Discard admin status
    }
  }

  Future<int> exitGroup(BuildContext context) async {
    final isConfirm = await CustomAlert.confirmAlert(
      context,
      "Are you sure you want to leave \"${membersMap[0]['GroupName']}\"?",
    );

    if (!isConfirm) return -1;

    if (context.mounted) CustomAlert.loadAlert(context, "Please wait...");

    try {
      final exitResult =
          await FirebaseApi.removeMember(membersMap[0]['roomId'], user.value);

      if (exitResult != 0) {
        if (context.mounted) {
          CustomAlert.errorAlert(context, "Failed to exit the group.");
        }
        return -1;
      }

      await FirebaseApi.userJoinLeft(
        "left",
        membersMap[0]["roomId"],
        userInfo?["usr"] ?? "",
      );

      // Get.offAll(() => Home());
      Get.back();
      Get.back();
      return 0;
    } catch (e) {
      if (context.mounted) {
        CustomAlert.errorAlert(context, "An error occurred: $e");
      }
      return -1;
    } finally {
      if (context.mounted) CustomAlert.dismissAlert(context);
    }
  }

  Future<void> submitForm() async {
    isLoad.value = true;
    String usn = groupNameController.text.trim();
    AppConstants.log.e(groupName.value);
    if (usn != groupName.value) {
      if ((usn.length < 3 || usn.length > 15) &&
          (usn.isEmpty || usn != groupName.value)) {
        Get.snackbar(
          backgroundColor: Colors.red.shade100,
          'Error',
          'Please enter valid Alphanumeric groupName not more than 15 letters',
        );
        return;
      } else {
        String gpName = usn;
        int sts =
            await FirebaseApi.updateRoomName(gpName, membersMap[0]["roomId"]);
        if (sts == 0) {
          groupName.value = gpName;
        } else {
          isValid.value = false;
          isNotValidMsg.value = "Something went wrong";
        }
      }
    }

    if (dpImagePath.value.isNotEmpty &&
        dpImagePath.value != finalDpImagePath.value) {
      String url = await FirebaseFileApi.uploadImage(
          "${DeviceInfo.deviceId}+${groupName.value}", dpImagePath.value, "dp");
      if (url.isNotEmpty) {
        int res = await FirebaseFileApi.updateImagePath(
            "roomDetail", membersMap[0]["roomId"], url, "dp");
        if (res == 0) {
          dpImagePath.value = url;
          finalDpImagePath.value = url;
          CustomWidget.confirmDialogue(
            title: "Room Updated Successfully",
            content: "Please Restart the app to get changes",
            isCancel: false,
          );
        } else {
          dpImagePath.value = "";
        }
      } else {}
    }
    isLoad.value = false;
  }
}
