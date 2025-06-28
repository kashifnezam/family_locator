import 'dart:async';
import 'package:family_room/api/firebase_tpr_api.dart';
import 'package:family_room/pages/auth/authentication.dart';
import 'package:family_room/pages/home.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/offline_data.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
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
  User? user;
  String? deviceId;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    saveUserData();
  }

  Future<void> requestLocationPermission() async {
    var status = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();

    if ((status[Permission.location]?.isGranted ?? false) &&
        (status[Permission.locationAlways]?.isGranted ?? false) &&
        (status[Permission.locationWhenInUse]?.isGranted ?? false)) {
      startLocationService();
    } else if ((status[Permission.location]?.isDenied ?? false) ||
        (status[Permission.locationAlways]?.isDenied ?? false) ||
        (status[Permission.locationWhenInUse]?.isDenied ?? false)) {
      print('Location permission denied');
    } else if ((status[Permission.location]?.isPermanentlyDenied ?? false) ||
        (status[Permission.locationAlways]?.isPermanentlyDenied ?? false) ||
        (status[Permission.locationWhenInUse]?.isPermanentlyDenied ?? false)) {
      openAppSettings();
    }
  }

  Future<void> startLocationService() async {
    const platform = MethodChannel('com.kashif.location_service');

    try {
      await platform.invokeMethod('startLocationUpdates');
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  // Future<void> stopLocationService() async {
  //   try {
  //     await platform.invokeMethod('stopLocationUpdates');
  //   } on PlatformException catch (e) {
  //     print("Failed to stop location service: ${e.message}");
  //   }
  // }

  /// Saves user data and uploads anonymous data if necessary
  Future<void> saveUserData() async {
    // 1. Check for version updates
    final Map<String, dynamic>? updates = await FirebaseApi.getVersionUpdate();
    if (!mounted) return;

    // Check if the app needs an update
    if (updates != null) {
      final bool isExpired = updates["expire"] as bool? ?? false;
      if (isExpired) {
        CustomAlert.errorAlert("plesase update your app to get latest features",
            title: "Update App");
        return; // Exit if the app needs an update
      }
    }

    // 2. Initialize offline data and device info
    final OfflineData offlineData = OfflineData();
    await offlineData.init();
    await DeviceInfo.getDetails();
    deviceId = DeviceInfo.deviceId;

    // 3. Retrieve user details and decide whether to save anonymous data
    // final userInform = await offlineData.getUserDetails();
    await offlineData.storeObject("uid", user?.uid);

    if (!mounted) return;

    await offlineData.refreshUserData(user?.uid);

    // 4. Initialize location tracking
    await initializeLocationTracking();

    // 5. Navigate to Home screen
    if (mounted) {
      Get.off(() => Home());
      await startLocationService();
    }
  }

  /// Initializes location tracking and sets up current location updates
  Future<void> initializeLocationTracking() async {
    // await LocationUtils.initializeBatchUpload();

    if (user != null && user?.uid != null) {
      FirebaseTprApi.cleanupOldRecords(user!.uid);
    }
    await LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        _currentLocation = location;
        if (_currentLocation != null && DeviceInfo.deviceId != null) {
          // FirebaseApi.updateLocation(
          //   _currentLocation.toString(),
          //   DeviceInfo.deviceId!,
          // );
        }
      },
      onError: (error) {
        AppConstants.log.e("Error getting location: $error");
      },
      onStartMoving: () {
        AppConstants.log.i("Person Starts Moving");
        if (_currentLocation != null && DeviceInfo.deviceId != null) {
          // FirebaseApi.updateLocation(
          //   _currentLocation.toString(),
          //   DeviceInfo.deviceId!,
          // );
        }
      },
    );
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
