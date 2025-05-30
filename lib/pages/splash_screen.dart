import 'dart:async';
import 'package:family_room/pages/home.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/offline_data.dart';
import 'package:family_room/widgets/custom_widget.dart';
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
  }

  /// Saves user data and uploads anonymous data if necessary
  Future<void> saveUserData() async {
    // 1. Check for version updates
    final Map<String, dynamic>? updates = await FirebaseApi.getVersionUpdate();
    if (!mounted) return;

    // Check if the app needs an update
    if (updates != null) {
      final bool isExpired = updates["expire"] as bool? ?? false;
      if (isExpired) {
        CustomAlert.errorAlert(
            context, "plesase update your app to get latest features",
            title: "Update App");
        return; // Exit if the app needs an update
      }
    }

    // 2. Initialize offline data and device info
    final OfflineData offlineData = OfflineData();
    await offlineData.init();
    await DeviceInfo.getDetails();

    // 3. Retrieve user details and decide whether to save anonymous data
    final userInform = await offlineData.getUserDetails();
    if (!mounted) return;

    if (userInform?["usr"] == null) {
      await SaveDataApi.saveAnonymousData(
        DeviceInfo.deviceId,
        DeviceInfo.macAddress,
        DeviceInfo.ipAddress,
      );
      await offlineData.refreshUserData(DeviceInfo.deviceId);
    }

    // 4. Initialize location tracking
    await initializeLocationTracking();

    // 5. Navigate to Home screen
    if (mounted) {
      Get.off(() => const Home());
    }
  }

  /// Initializes location tracking and sets up current location updates
  Future<void> initializeLocationTracking() async {
    await LocationUtils.initializeBatchUpload();
    await LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        _currentLocation = location;
        if (_currentLocation != null && DeviceInfo.deviceId != null) {
          FirebaseApi.updateLocation(
            _currentLocation.toString(),
            DeviceInfo.deviceId!,
          );
        }
      },
      onError: (error) {
        AppConstants.log.e("Error getting location: $error");
      },
      onStartMoving: () {
        AppConstants.log.i("Person Starts Moving");
        if (_currentLocation != null && DeviceInfo.deviceId != null) {
          FirebaseApi.updateLocation(
            _currentLocation.toString(),
            DeviceInfo.deviceId!,
          );
        }
      },
    );
      
//     await BackgroundLocation.setAndroidConfiguration(1000);
//     // Start the background location service with a specified distance filter
//     await BackgroundLocation.startLocationService(distanceFilter: 20);

// // Listen for location updates
//     BackgroundLocation.getLocationUpdates((location) {
//       // Check if current location and device ID are not null
//       if (_currentLocation != null && DeviceInfo.deviceId != null) {
//         String currLoc = LatLng(
//                 location.latitude!.toDouble(), location.longitude!.toDouble())
//             .toString();
//         // Update the location in Firebase
//         FirebaseApi.updateLocation(
//           currLoc,
//           DeviceInfo.deviceId!,
//         );
//         AppConstants.log.e("Cuurent Location: $currLoc");
//       }
//     });
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
                  "Family Room",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          CustomWidget.buildCircularProgressIndicator(),
          const Padding(
            padding: EdgeInsets.only(bottom: 30.0, top: 10),
            child: Text(
              "Developed by: Md Kashif Nezam",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
