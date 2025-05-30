import 'dart:io';

import 'package:family_room/controller/profile_controller.dart';
import 'package:family_room/widgets/button_widget.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    _controller.getUserNameDP();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          actions: [
            Obx(
              () => Row(
                children: [
                  if (_controller.userNameEdit.value ||
                      _controller.isLoad.value)
                    GestureDetector(
                      onTap: () {
                        _controller.submitForm();
                        _controller.userNameEdit.value = false;
                        _controller.userNameController.text =
                            _controller.username.value;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: !_controller.isLoad.value
                            ? ButtonWidget.elevatedBtn(
                                "Save",
                                height: AppConstants.height * 0.05,
                                width: AppConstants.width * 0.2,
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                    right: AppConstants.width * 0.2),
                                child: CustomWidget
                                    .buildCircularProgressIndicator(),
                              ),
                      ),
                    ),
                  if (_controller.userNameEdit.value &&
                      !_controller.isLoad.value)
                    GestureDetector(
                      onTap: () {
                        _controller.userNameEdit.value = false;
                        _controller.userNameController.text =
                            _controller.username.value;
                        _controller.dpImagePath.value =
                            _controller.finalDpImagePath.value;
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
        body: Obx(
          () {
            return ListView(
              children: [
                _buildProfilePictureSection(),
                const SizedBox(height: 20),
                if (!_controller.userNameEdit.value)
                  ListTile(
                    leading: const Icon(Icons.person_4_sharp),
                    title: Text(_controller.username.value),
                    subtitle: const Text(
                      "username",
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: GestureDetector(
                        onTap: () {
                          _controller.userNameEdit.value = true;
                        },
                        child: const Icon(Icons.edit)),
                  ),
                if (_controller.userNameEdit.value)
                  ListTile(
                    leading: const Icon(Icons.person_4_sharp),
                    title: TextField(
                      controller: _controller.userNameController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Enter Username',
                        border: OutlineInputBorder(),
                        errorText: _controller.isValid.value
                            ? null
                            : _controller.isNotValidMsg.toString(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ));
  }

  /// Builds the profile picture section with an editable avatar.
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
                child: _controller.dpImagePath.value.isEmpty
                    ? CircleAvatar(
                        radius: AppConstants.width * 0.3,
                        child: Text(
                          _controller.username.value
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : _controller.dpImagePath.value.startsWith('http')
                        ? CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            child: CustomWidget.getImage(
                                _controller.dpImagePath.value),
                          )
                        : CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            backgroundImage:
                                FileImage(File(_controller.dpImagePath.value)),
                          ),
              );
            }),
            _buildEditIcon(),
          ],
        ),
      ),
    );
  }

  /// Builds the edit icon that appears on the profile picture.
  Widget _buildEditIcon() {
    return Positioned(
      bottom: 20,
      right: 10,
      child: GestureDetector(
        onTap: () async {
          // Opens image picker and updates the profile image
          String tempPath = await CustomWidget.imagePickFrom();
          if (tempPath.isNotEmpty) {
            _controller.dpImagePath.value = tempPath;
            _controller.userNameEdit.value = true;
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
}
