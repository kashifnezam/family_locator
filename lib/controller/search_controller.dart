import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../api/firebase_api.dart';
import '../api/map_utils.dart';
import '../api/save_data.dart';
import '../utils/device_info.dart';
import '../utils/location_utils.dart';

class SController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isSearchLoading = false.obs;
  LatLng? currentLocation;
  LatLng? markerPosition;
  bool isLocPer = false;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
  }

  void _onSearchChanged() {
    if (searchController.text.length >= 4) {
      _searchLocations(searchController.text);
    } else {
      searchResults.clear();
    }
  }

  Future<void> _searchLocations(String query) async {
    isSearchLoading.value = true;
    try {
      List<dynamic> results = await searchPlace(query);
      searchResults.assignAll(results);
    } catch (e) {
      Get.defaultDialog(
        title: "Failed to search locations",
        onConfirm: () {
          Get.back();
        },
      );
    } finally {
      isSearchLoading.value = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    isLocPer = true;
    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        currentLocation = location;
        isLocPer = false;
      },
      onError: (error) {
        isLocPer = false;
      },
      onStartMoving: () {
        if (DeviceInfo.deviceId != null) {
          FirebaseApi.updateLocation(currentLocation.toString(), DeviceInfo.deviceId!);
        }
      },
    );
    await saveUserData();
  }

  Future<void> saveUserData() async {
    await DeviceInfo.getDetails().then((x) {
      SaveDataApi.saveAnonymousData(DeviceInfo.deviceId, DeviceInfo.macAddress,
          DeviceInfo.ipAddress, currentLocation.toString());
    });
  }
}