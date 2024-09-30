import 'package:get/get.dart';

class MembersController extends GetxController {
  var membersMap = <Map<String, dynamic>>[].obs; // Observable list of maps
  var groupName = ''.obs; // Observable for group name
  RxBool isOwner = false.obs;
  RxBool isAdmin = false.obs;

  void setMembers(List<Map<String, dynamic>> newMembers) {
    membersMap.assignAll(newMembers); // Update the members map
    groupName.value = newMembers[0]['GroupName']; // Set initial group name
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
}
