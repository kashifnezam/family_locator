// controllers/member_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:get/get.dart';
import '../../models/user_modal/member_model.dart';
import '../../service/member_service.dart';

class MemberController extends GetxController {
  final MemberService _memberService = MemberService();
  final RxList<Member> members = <Member>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading(true);
      final currentUser = DeviceInfo.userUID;
      if (currentUser != null) {
        members.value = await _memberService.getMembers(currentUser);
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> createMember({
    required String fullname,
    required String email,
    required String mobile,
    required String username
  }) async {
    try {
      isLoading(true);
      final currentUser = DeviceInfo.userUID;
      if (currentUser != null) {
        final newMember = Member(
          uid: DateTime.now().millisecondsSinceEpoch.toString(),
          fullname: fullname,
          email: email,
          mobile: mobile,
          createdBy: currentUser,
          dateCreated: Timestamp.now(),
          username: username,
        );

        await _memberService.createMember(newMember);
        members.add(newMember);
        Get.back(); // Close the create member dialog
        Get.snackbar('Success', 'Member created successfully');
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to create member');
    } finally {
      isLoading(false);
    }
  }
}