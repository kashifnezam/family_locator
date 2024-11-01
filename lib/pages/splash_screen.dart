import 'dart:async';
import 'package:background_fetch/background_fetch.dart';
import 'package:family_locator/pages/home.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/offline_data.dart';
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
  bool enabled = true;
  int gStatus = 0;
  List<DateTime> events = [];

  @override
  void initState() {
    super.initState();
    bgTaskConfig();
    saveUserData();
    LocationUtils.initializeBatchUpload();
    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        _currentLocation = location;
        if (_currentLocation != null && DeviceInfo.deviceId != null) {
          FirebaseApi.updateLocation(
              _currentLocation.toString(), DeviceInfo.deviceId!);
        }
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
    await DeviceInfo.getDetails().then((x) async {
      if (await OfflineData.getData("usr") == null) {
        SaveDataApi.saveAnonymousData(
          DeviceInfo.deviceId,
          DeviceInfo.macAddress,
          DeviceInfo.ipAddress,
        );
      }
    });
  }

  Future<void> bgTaskConfig() async {
    await initPlatformState();
    enableBGTask();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      AppConstants.log.i("[BackgroundFetch] Event received $taskId");
      events.insert(0, DateTime.now());
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      AppConstants.log.e("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    AppConstants.log.i('[BackgroundFetch] configure success: $status');
    setState(() {
      gStatus = status;
    });
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void enableBGTask() {
    BackgroundFetch.start().then((int status) {
      LocationUtils.initializeBatchUpload();
      LocationUtils.getCurrentLocation(
        onLocationLoaded: (location) {
          _currentLocation = location;
          if (_currentLocation != null && DeviceInfo.deviceId != null) {
            FirebaseApi.updateLocation(
                _currentLocation.toString(), DeviceInfo.deviceId!);
          }
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
    }).catchError((e) {
      AppConstants.log.e('[BackgroundFetch] start FAILURE: $e');
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
