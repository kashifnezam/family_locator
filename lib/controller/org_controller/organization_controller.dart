// controllers/organization_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../api/firebase_file_api.dart';
import '../../models/org_model/org_model.dart';

class OrganizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<Organization?> _organization = Rx<Organization?>(null);
  Organization? get organization => _organization.value;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  RxString logoImagePath = ''.obs;
  final isLogoChanged = false.obs;

  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  final List<String> organizationTypes = [
    'school',
    'home',
    'charity',
    'business',
    'non-profit',
    'government',
    'religious',
    'other'
  ]..toSet().toList(); // This ensures all values are unique

  @override
  void onInit() {
    super.onInit();
    fetchOrganization();

  }

  @override
  void onClose() {
    nameController.dispose();
    typeController.dispose();
    latController.dispose();
    lngController.dispose();
    super.onClose();
    super.onClose();
  }

  // controllers/organization_controller.dart
  LatLng? get selectedLatLng {
    if (latController.text.isEmpty || lngController.text.isEmpty) return null;
    return LatLng(
      double.tryParse(latController.text) ?? 0,
      double.tryParse(lngController.text) ?? 0,
    );
  }

  void updateLocation(LatLng latLng) {
    latController.text = latLng.latitude.toStringAsFixed(3);
    lngController.text = latLng.longitude.toStringAsFixed(3);
    update();
  }

  Future<void> fetchOrganization() async {
    try {
      isLoading(true);
      // In a real app, you would get the organization ID from user data
      // For demo, we'll just get the first organization
      final querySnapshot = await _firestore.collection('organizations').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        _organization(Organization.fromFirestore(querySnapshot.docs.first));
        _updateControllers();
      }
    } catch (e) {
      CustomAlert.errorAlert('Failed to fetch organization: $e');
    } finally {
      isLoading(false);
    }
  }

  void _updateControllers() {
    if (organization != null) {
      nameController.text = organization!.name;
      typeController.text = organization!.type;
      latController.text = organization?.latitude ?? '';
      lngController.text = organization?.longitude ?? '';
      logoImagePath.value = organization?.logoUrl ?? '';
    } else {
      // Set default values for new organization
      nameController.text = '';
      typeController.text = organizationTypes.first; // Default to first type
      latController.text = '';
      lngController.text = '';
    }
  }

  Future<void> saveOrganization() async {
    try {
      isLoading(true);
      errorMessage('');

      // Validate required fields
      if (nameController.text.trim().isEmpty) {
        CustomAlert.errorAlert('Organization name is required');
        return;
      }

      if (typeController.text.trim().isEmpty) {
        CustomAlert.errorAlert('Organization type is required');
        return;
      }

      // Validate coordinates
      final latError = validateCoordinate(latController.text, isLatitude: true);
      final lngError = validateCoordinate(lngController.text, isLatitude: false);

      if (latError != null || lngError != null) {
        CustomAlert.errorAlert(latError ?? lngError ?? 'Invalid location data');
        return;
      }


      // Handle logo upload if changed
      if (isLogoChanged.value && logoImagePath.value.isNotEmpty && !logoImagePath.value.startsWith('http')) {
        CustomAlert.loadAlert('Uploading logo...');

        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'org_logo_$timestamp';

          logoImagePath.value = await FirebaseFileApi.uploadImage(
              fileName,
              logoImagePath.value,
              'organizations'
          );

          if (logoImagePath.value.isEmpty) {
            CustomAlert.errorAlert('Failed to upload logo');
            return;
          }

          // Update the logo URL controller if this is a new organization
        } catch (e) {
          CustomAlert.dismissAlert();
          CustomAlert.errorAlert('Logo upload failed: ${e.toString()}');
          return;
        } finally {
          CustomAlert.dismissAlert();
        }
      }

      // Prepare GeoPoint from coordinates
      final GeoPoint location = GeoPoint(
        double.parse(latController.text.trim()),
        double.parse(lngController.text.trim()),
      );

      final newOrg = Organization(
        id: organization?.id,
        name: nameController.text.trim(),
        type: typeController.text.trim(),
        latitude: latController.text.trim(),
        longitude: lngController.text.trim(),
        createdAt: organization?.createdAt ?? DateTime.now(),
        createdBy: organization?.createdBy ?? DeviceInfo.userUID ?? 'unknown',
        logoUrl: logoImagePath.value,
        location: location,
        active: organization?.active ?? true,
      );

      // Save to Firestore
      if (newOrg.id == null) {
        final docRef = await _firestore.collection('organizations').add(newOrg.toFirestore());

        // Update the logo path if this is a new organization with uploaded logo
        if (isLogoChanged.value) {
          await FirebaseFileApi.updateImagePath(
              'organizations',
              docRef.id,
              logoImagePath.value,
              'logoUrl'
          );
        }

        CustomAlert.successAlert('Organization created successfully');
      } else {
        await _firestore.collection('organizations').doc(newOrg.id).update(newOrg.toFirestore());
        CustomAlert.successAlert('Organization updated successfully');
      }

      // Reset changed flags and refresh data
      isLogoChanged.value = false;
      await fetchOrganization();

    } catch (e, stackTrace) {
      debugPrint('Save organization error: $e\n$stackTrace');
      CustomAlert.errorAlert('Failed to save organization: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  // Add this to your OrganizationController
  String? validateCoordinate(String? value, {bool isLatitude = true}) {
    if (value == null || value.isEmpty) return null;

    final numValue = double.tryParse(value);
    if (numValue == null) return 'Invalid number';

    if (isLatitude && (numValue < -90 || numValue > 90)) {
      return 'Latitude must be between -90 and 90';
    }

    if (!isLatitude && (numValue < -180 || numValue > 180)) {
      return 'Longitude must be between -180 and 180';
    }

    return null;
  }
}