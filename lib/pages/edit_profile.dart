import 'package:family_locator/controller/profile_controller.dart';
import 'package:family_locator/widgets/button_widget.dart';
import 'package:family_locator/widgets/custom_widget.dart';
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
                        child: const Text(
                          "MK",
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ) // Show initials if no image
                    : CustomWidget.getImage(_controller.dpImagePath.value),
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
          _controller.dpImagePath.value = await CustomWidget.imagePickFrom();
          if (_controller.dpImagePath.value.isNotEmpty) {
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
