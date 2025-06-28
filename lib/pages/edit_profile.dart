import 'dart:io';
import 'package:family_room/controller/profile_controller.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _controller.getUserProfileData();
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfilePictureSection(),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: "Full Name",
                      icon: Icons.person_outline,
                      value: _controller.fullName.value,
                      controller: _controller.fullNameController,
                      enabled: _controller.isEditing.value,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your full name'
                          : null,
                    ),
                    _buildProfileField(
                      label: "Username",
                      icon: Icons.alternate_email,
                      value: _controller.username.value,
                      controller: _controller.userNameController,
                      enabled: _controller.isEditing.value,
                      validator: (value) {
                        _controller.validateUsername(value);
                        if (_controller.isNotValidMsg.value.isNotEmpty) {
                          return _controller.isNotValidMsg.value;
                        }
                        return null;
                      },
                    ),
                    _buildProfileField(
                      label: "Email",
                      readOnly: true,
                      icon: Icons.email_outlined,
                      value: _controller.email.value,
                      controller: _controller.emailController,
                      enabled: _controller.isEditing.value,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.isEmail ?? false
                          ? null
                          : 'Enter a valid email',
                    ),
                    _buildProfileField(
                      label: "Mobile Number",
                      icon: Icons.phone_android,
                      value: _controller.mobile.value,
                      controller: _controller.mobileController,
                      enabled: _controller.isEditing.value,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isPhoneNumber ?? false
                          ? null
                          : 'Enter valid phone number',
                    ),
                    if (_controller.isEditing.value) _buildSaveButton(),

                  ],

                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("My Profile"),
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                _controller.isEditing.value ? Icons.close : Icons.edit,
                color: Colors.black,
              ),
              onPressed: () {
                if (_controller.isEditing.value) {
                  _controller.cancelEditing();
                } else {
                  _controller.startEditing();
                }
              },
            )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _submitForm,
      icon: _controller.isLoading.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check),
      label: _controller.isLoading.value
          ? const Text("Saving...")
          : const Text("SAVE CHANGES"),
    );
  }

  Widget _buildProfileField({
    required String label,
    required IconData icon,
    required String value,
    required TextEditingController controller,
    required bool enabled,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller..text = value,
        enabled: enabled,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _controller.submitForm();
    }
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
            if (_controller.isEditing.value) _buildEditIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditIcon() {
    return Positioned(
      bottom: 20,
      right: 10,
      child: GestureDetector(
        onTap: () async {
          String tempPath = await CustomWidget.imagePickFrom();
          if (tempPath.isNotEmpty) {
            _controller.dpImagePath.value = tempPath;
            _controller.userNameEdit.value = true;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.blue,
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
