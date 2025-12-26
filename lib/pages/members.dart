import 'dart:io';

import 'package:family_room/utils/constants.dart';
import 'package:family_room/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/members_controller.dart';
import '../utils/custom_alert.dart';
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
    final hasGroupInfo = controller.membersMap.isNotEmpty;

    isOwner = hasGroupInfo && controller.user.value == controller.membersMap[0]['ownerId'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Members'),
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
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
                onTap: () async {
                  await controller.exitGroup().then(
                    (value) {
                      if (value == 0 && context.mounted && controller.membersMap.isNotEmpty) {
                        CustomAlert.successAlert(
                            "You have exited from Room: ${controller.membersMap[0]['GroupName']}");
                      }
                    },
                  );
                },
                child: ButtonWidget.elevatedBtn(
                  "Exit Room",
                  borderColor: Colors.red,
                  height: AppConstants.height * 0.06,
                ),
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
                child: controller.dpImagePath.value.isEmpty
                    ? CircleAvatar(
                        radius: AppConstants.width * 0.3,
                        child: const Text(
                          "MK",
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : controller.dpImagePath.value.startsWith('http')
                        ? CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            child: CustomWidget.getImage(
                                controller.dpImagePath.value),
                          )
                        : CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            backgroundImage: FileImage(
                              File(controller.dpImagePath.value),
                            ),
                          ),
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
      bottom: 20,
      right: 15,
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
    final total = controller.membersMap.length;

    // first element (index 0) is group info, so members start from index 1
    final memberCount = total > 1 ? total - 1 : 0;

    if (memberCount == 0) {
      return const Center(
        child: Text('No members found'),
      );
    }
    return ListView.builder(
      itemCount: memberCount, // Exclude group info
      itemBuilder: (context, index) {
        final member =
            controller.membersMap[index + 1]; // Skip group info at index 0
        return ListTile(
          leading: CircleAvatar(
            child: member['profileUrl'] == ""
                ? const Icon(Icons.person_4_outlined)
                : CustomWidget.getImage(member['profileUrl']),
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
                  // controller.promoteToAdmin(memberIndex);
                  Get.back(); // Close the modal
                },
              ),
            ],
            if (controller.isAdmin.value || isOwner) ...[
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Discard Admin'),
                onTap: () {
                  // controller.discardAdmin(memberIndex);
                  Get.back(); // Close the modal
                },
              ),
            ],
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Member'),
                onTap: () async {
                  String name = controller.membersMap[memberIndex]["name"];
                  final isConfirm = await CustomAlert.confirmAlert(
                    "Are you sure want to remove \"$name\"?",
                  );
                  if (isConfirm) {
                    controller.removeMember(memberIndex);
                  }
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
