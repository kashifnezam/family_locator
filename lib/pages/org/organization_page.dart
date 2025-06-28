// views/organization_settings_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/org_controller/organization_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_widget.dart';
import '../../widgets/location-picker-widget.dart';

class OrganizationSettingsPage extends StatelessWidget {
  OrganizationSettingsPage({super.key});

  final OrganizationController controller = Get.put(OrganizationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: controller.saveOrganization,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.organization == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogoSection(),
              const SizedBox(height: 24),
              _buildFormSection(context),
              // if (controller.errorMessage.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 16.0),
              //     child: Text(
              //       controller.errorMessage.value,
              //       style: TextStyle(color: Colors.red.shade700),
              //     ),
              //   ),
            ],
          ),
        );
      }),
    );
  }

/*
  Widget _buildLogoSection() {
    return Column(
      children: [
        Obx(() {
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: controller.logoImagePath.value.isNotEmpty
                ? controller.logoImagePath.value.startsWith('http')
                ? NetworkImage(controller.logoImagePath.value)
                : FileImage(File(controller.logoImagePath.value)) as ImageProvider
                : null,
            child: controller.logoImagePath.value.isEmpty
                ? const Icon(Icons.business, size: 50, color: Colors.grey)
                : null,
          );
        }),

        TextButton(
          onPressed: () async {
            // Use the same image picking logic from profile page
            String? imagePath = await CustomWidget.imagePickFrom();
            if (imagePath.isNotEmpty) {
              controller.logoImagePath.value = imagePath;
              controller.isLogoChanged.value = true;
            }
          },
          child: const Text('Change Logo'),
        ),
      ],
    );
  }
*/

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Obx(() {
              return CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: AppConstants.width * 0.2,
                child: controller.logoImagePath.value.isEmpty
                    ? CircleAvatar(
                        radius: AppConstants.width * 0.3,
                        child: Text(
                          "Organization Logo".substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : controller.logoImagePath.value.startsWith('http')
                        ? CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            child: CustomWidget.getImage(
                                controller.logoImagePath.value),
                          )
                        : CircleAvatar(
                            radius: AppConstants.width * 0.3,
                            backgroundImage:
                                FileImage(File(controller.logoImagePath.value)),
                          ),
              );
            }),
          ),
          TextButton(
            onPressed: () async {
              // Use the same image picking logic from profile page
              String? imagePath = await CustomWidget.imagePickFrom();
              if (imagePath.isNotEmpty) {
                controller.logoImagePath.value = imagePath;
                controller.isLogoChanged.value = true;
              }
            },
            child: const Text('Change Logo'),
          ),
        ],
      ),
    );
  }

// Update the _buildFormSection() widget in organization_settings_page.dart
  Widget _buildFormSection(BuildContext context) {
    // Ensure we have a valid initial value
    String initialType = controller.typeController.text;
    if (initialType.isEmpty ||
        !controller.organizationTypes.contains(initialType)) {
      initialType = controller.organizationTypes.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            labelText: 'Organization Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: initialType, // Use the validated initial value
          decoration: const InputDecoration(
            labelText: 'Organization Type',
            border: OutlineInputBorder(),
          ),
          items: controller.organizationTypes
              .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type.capitalizeFirst!,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.typeController.text = value;
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.latController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 37.7749',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller.lngController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. -122.4194',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showLocationPicker(context),
          icon: const Icon(Icons.map_outlined, size: 20),
          label: const Text(
            'Pick Location',
            style: TextStyle(
              color: Colors.blueAccent, // More vibrant blue
              fontWeight: FontWeight.w600, // Semi-bold instead of bold
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.blueAccent, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: Colors.blueAccent.withAlpha(1),
            // Subtle background tint
            elevation: 0,
          ),
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.saveOrganization,
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Organization'),
            )),
      ],
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: LocationPicker(
          initialLocation: controller.selectedLatLng,
          onLocationSelected: (latLng) {
            controller.updateLocation(latLng);
          },
        ),
      ),
    );
  }
}
