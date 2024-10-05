import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/members_controller.dart';

late bool isOwner;

class MembersPage extends StatelessWidget {
  final MembersController controller = Get.put(MembersController());

  MembersPage(
      {super.key,
      required List<Map<String, dynamic>> initialMembers,
      required String user,
      required bool isAdmin}) {
    controller.setMembers(initialMembers); // Set initial members
    controller.user.value = user;
    controller.isAdmin.value = isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    isOwner = controller.user.value == controller.membersMap[0]['ownerId'];
    return Scaffold(
      appBar: AppBar(title: const Text('Group Members')),
      body: Obx(() {
        return Column(
          children: [
            _buildGroupHeader(),
            Expanded(child: _buildMemberList()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  controller.exitGroup();
                },
                child: ButtonWidget.elevatedBtn("Exit Group",
                    borderColor: Colors.red),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGroupHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: AppConstants.width * 0.3,
            backgroundImage: controller.membersMap[0]['dp'] != ""
                ? NetworkImage(controller.membersMap[0]['dp'])
                : null,
            child: controller.membersMap[0]['dp'] == ""
                ? Icon(
                    Icons.groups_3_sharp,
                    size: AppConstants.width * 0.3,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: controller.groupName.value),
            onSubmitted: (newName) => controller.updateGroupName(newName),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      itemCount: controller.membersMap.length - 1, // Exclude group info
      itemBuilder: (context, index) {
        final member =
            controller.membersMap[index + 1]; // Skip group info at index 0
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: member['profileUrl'] != ""
                ? NetworkImage(member['profileUrl'])
                : null,
            child: member['profileUrl'] == ""
                ? const Icon(Icons.person_4_outlined)
                : null,
          ),
          title: Text(member['name']),
          subtitle: Text(
            member['isOwner'] ?? false
                ? 'Owner'
                : member['isAdmin']
                    ? 'Admin'
                    : 'Member',
            style: TextStyle(
                color: member['isOwner'] ?? false
                    ? Colors.red
                    : member['isAdmin']
                        ? Colors.blue
                        : Colors.grey),
          ),
          onTap: () => isOwner
              ? !member['isOwner']
                  ? _showOptions(context, index + 1)
                  : null
              : null, // Pass actual member index
        );
      },
    );
  }

  void _showOptions(BuildContext context, int memberIndex) {
    final member = controller.membersMap[memberIndex];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            if (!member['isAdmin'] && isOwner) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Set as Admin'),
                onTap: () {
                  controller.promoteToAdmin(memberIndex);
                  Get.back(); // Close the modal
                },
              ),
            ],
            if (controller.isAdmin.value || isOwner) ...[
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Discard Admin'),
                onTap: () {
                  controller.discardAdmin(memberIndex);
                  Get.back(); // Close the modal
                },
              ),
            ],
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Member'),
                onTap: () {
                  controller.removeMember(memberIndex);
                  Get.back(); // Close the modal
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
