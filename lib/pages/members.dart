import 'dart:io';

import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/members_controller.dart';
import '../widgets/custom_widget.dart';

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
      appBar: AppBar(
        title: const Text('Group Members'),
        actions: [
          Obx(
            () => Row(
              children: [
                if (controller.groupNameEdit.value || controller.isLoad.value)
                  GestureDetector(
                    onTap: () {
                      controller.submitForm();
                      controller.groupNameEdit.value = false;
                      controller.groupNameController.text =
                          controller.groupName.value;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: !controller.isLoad.value
                          ? ButtonWidget.elevatedBtn(
                              "Save",
                              height: AppConstants.height * 0.05,
                              width: AppConstants.width * 0.2,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  right: AppConstants.width * 0.2),
                              child:
                                  CustomWidget.buildCircularProgressIndicator(),
                            ),
                    ),
                  ),
                if (controller.groupNameEdit.value && !controller.isLoad.value)
                  GestureDetector(
                    onTap: () {
                      controller.groupNameEdit.value = false;
                      controller.dpImagePath.value =
                          controller.finalDpImagePath.value;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ButtonWidget.elevatedBtn("Cancel",
                          height: AppConstants.height * 0.05,
                          width: AppConstants.width * 0.2,
                          disabled: true),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildProfilePictureSection(),
            const SizedBox(height: 10),
            if (!controller.groupNameEdit.value)
              ListTile(
                leading: const Icon(Icons.groups_3_outlined),
                title: Text(controller.groupName.value),
                subtitle: const Text(
                  "Room Name",
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: GestureDetector(
                    onTap: () {
                      controller.groupNameEdit.value = true;
                    },
                    child: const Icon(Icons.edit)),
              ),
            if (controller.groupNameEdit.value)
              ListTile(
                leading: const Icon(Icons.groups_3_outlined),
                title: TextField(
                  controller: controller.groupNameController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Enter Room Name',
                    border: OutlineInputBorder(),
                    errorText: controller.isValid.value
                        ? null
                        : controller.isNotValidMsg.toString(),
                  ),
                ),
              ),
            Divider(
              color: Colors.grey,
            ),
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

  Widget _buildProfilePictureSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.blueGrey,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(() {
              return CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: AppConstants.width * 0.3,
                backgroundImage: controller.dpImagePath.value.isNotEmpty
                    ? (controller.dpImagePath.value.startsWith('http')
                        ? NetworkImage(
                            controller.dpImagePath.value) // If it's a URL
                        : FileImage(File(controller
                            .dpImagePath.value))) // If it's a local file
                    : null,
                child: controller.dpImagePath.value.isEmpty
                    ? CircleAvatar(
                        radius: AppConstants.width * 0.3,
                        child: Text(
                          controller.groupName.value
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ) // Show initials if no image
                    : null,
              );
            }),
            _buildEditIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditIcon() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: GestureDetector(
        onTap: () async {
          // Opens image picker and updates the profile image
          String tempDP = await CustomWidget.imagePickFrom();
          if (tempDP.isNotEmpty) {
            controller.dpImagePath.value = tempDP;
            controller.groupNameEdit.value = true;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.blue, // Background color for the edit icon
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera,
            color: Colors.white,
            size: 20,
          ),
        ),
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
