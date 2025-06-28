// pages/members/member_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user/member_controller.dart';
import 'create_member_page.dart';

class MemberListScreen extends StatelessWidget {
  final MemberController _memberController = Get.put(MemberController());

  MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => CreateMemberScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (_memberController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_memberController.members.isEmpty) {
          return const Center(child: Text('No members found'));
        }

        return ListView.builder(
          itemCount: _memberController.members.length,
          itemBuilder: (context, index) {
            final member = _memberController.members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(member.fullname[0].toUpperCase()),
              ),
              title: Text(member.fullname),
              subtitle: Text(member.email ?? ""),
              trailing: Text(member.role),
              onTap: () {
                // Navigate to member details if needed
              },
            );
          },
        );
      }),
    );
  }
}
