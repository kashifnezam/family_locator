import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/pages/home.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
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
    groupName.value = newMembers[0]['GroupName']; // Set initial group name
    groupNameController.text = groupName.value;
    dpImagePath.value = newMembers[0]['dp'];
    finalDpImagePath.value = newMembers[0]['dp'];
  }

  void updateGroupName(String newName) {
    groupName.value = newName; // Update group name
    membersMap[0]['GroupName'] = newName; // Update in the members map
  }

  void removeMember(int index) {
    if (index > 0 && index < membersMap.length) {
      membersMap.removeAt(index); // Remove member from the list
    }
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

  Future<void> exitGroup() async {
    bool isConfirm = await CustomWidget.confirmDialogue(
      title: "Leave Room",
      content: "Are you sure want to leave \"${membersMap[0]['GroupName']}\"",
      isCancel: true,
    );
    if (isConfirm) {
      FirebaseApi.exitGroup(membersMap[0]['roomId'], user.value).then(
        (value) {
          if (value == 0) {
            Get.off(() => Home());
            CustomWidget.confirmDialogue(
              title: "Exited Successfully",
              content:
                  "You are exited from Group : ${membersMap[0]['GroupName']}",
              isCancel: false,
            );
          }
        },
      );
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
        String gpName = usn.toLowerCase();
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
