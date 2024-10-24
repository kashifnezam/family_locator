import 'dart:async';
import 'package:family_locator/pages/home.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../api/firebase_api.dart';
import '../api/save_data.dart';
import '../utils/device_info.dart';
import '../utils/location_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    saveUserData();

    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        _currentLocation = location;
        FirebaseApi.updateLocation(
              _currentLocation.toString(), DeviceInfo.deviceId!);
      },
      onError: (error) {
        AppConstants.log.e("Error getting location: $error");
      },
      onStartMoving: () {
        AppConstants.log.i("Person Starts Moving");
        if (DeviceInfo.deviceId != null) {
          FirebaseApi.updateLocation(
              _currentLocation.toString(), DeviceInfo.deviceId!);
        }
      },
    );

    Timer(const Duration(seconds: 2), () {
      Get.off(() => Home());
    });
  }

  Future<void> saveUserData() async {
    await DeviceInfo.getDetails().then((x) {
      SaveDataApi.saveAnonymousData(DeviceInfo.deviceId, DeviceInfo.macAddress,
          DeviceInfo.ipAddress, _currentLocation.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: AppConstants.height / 5,
                ),
                const Center(
                  child: Image(
                    height: 300,
                    image: AssetImage(
                      "assets/logo/logo.png",
                    ),
                  ),
                ),
                const Text(
                  "Family Locator",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            child: Text(
              "Developed by: Md Kashif Nezam",
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
